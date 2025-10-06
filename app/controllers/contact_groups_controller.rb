## `./app/controllers/contact_groups_controller.rb`

'''
### ContactGroupsController

  **Descrição:**  
  Controlador responsável por gerenciar grupos de contatos (ContactGroups). Inclui operações de CRUD, adição e remoção de membros.

  **Ações:**
  - `index`: Lista todos os grupos de contatos visíveis ao usuário atual, com suporte a paginação e formato API
  - `show`: Exibe os detalhes de um grupo, incluindo a lista de membros (contatos)
  - `new`: Inicializa um novo grupo de contatos
  - `create`: Cria um novo grupo de contatos
  - `edit`: Prepara a edição de um grupo existente
  - `update`: Atualiza os dados de um grupo
  - `destroy`: Exclui um grupo, se permitido
  - `add_member`: Adiciona um contato como membro do grupo
  - `remove_member`: Remove um contato do grupo

  **Filtros:**
  - `require_login`: Garante que o usuário está autenticado
  - `find_contact_group`: Carrega o grupo de contatos com base no `params[:id]`
  - `authorize_global`: Verifica permissões globais do usuário

---
'''

class ContactGroupsController < ApplicationController
  before_action :require_login
  before_action :find_contact_group, only: [:show, :edit, :update, :destroy, :add_member, :remove_member, :search_members]
  before_action :authorize_global
  
  def index
    scope = ContactGroup.visible(User.current).includes(:author, :issues).order(:name)
    @group_count = scope.count
    @group_pages = Paginator.new @group_count, per_page_option, params['page']
    @contact_groups = scope.offset(@group_pages.offset).limit(@group_pages.per_page).to_a

    respond_to do |format|
      format.html
      format.api
    end
  end
  
  def show
    @members = @contact_group.contacts.includes(:author).order(:name)
    @issues = @contact_group.issues.visible.order(updated_on: :desc)
    
    respond_to do |format|
      format.html
      format.api
    end
  end

  def search_members
    query = params[:q].to_s.strip.downcase
    @contacts = if query.present?
                  Contact.visible(User.current)
                         .where("LOWER(name) LIKE ?", "%#{query}%")
                         .where.not(id: @contact_group.contact_ids)
                         .limit(10)
                else
                  []
                end
    # Implicitly renders search_members.html.erb
  end
  
  def new
    @contact_group = ContactGroup.new(author: User.current)
    @contact_group.safe_attributes = params[:contact_group]
  end
  
  def create
    # Check for issue_id context BEFORE safe_attributes strips it
    is_issue_context = params.dig(:contact_group, :issue_id).present?

    @contact_group = ContactGroup.new(author: User.current)
    @contact_group.safe_attributes = params[:contact_group]

    if is_issue_context
      handle_issue_context_creation
    else
      handle_standard_creation
    end
  end

  def edit
  end
    
  def update
    @contact_group.safe_attributes = params[:contact_group]
    
    if @contact_group.save
      respond_to do |format|
        format.html {
          flash[:notice] = l(:notice_contact_group_updated)
          redirect_to contact_group_path(@contact_group)
        }
        format.api { render_api_ok }
      end
    else
      respond_to do |format|
        format.html { render action: 'edit' }
        format.api { render_validation_errors(@contact_group) }
      end
    end
  end
  
  def destroy
    if @contact_group.deletable?
      @contact_group.destroy
      flash[:notice] = l(:notice_successful_delete)
      respond_to do |format|
        format.html { redirect_to contact_groups_path }
        format.turbo_stream { render turbo_stream: turbo_stream.remove(@contact_group) }
      end
    else
      flash[:error] = l(:error_contact_group_not_deletable)
      redirect_to contact_groups_path
    end
  end
  
  def add_member
    @contact = Contact.find(params[:contact_id])
    @membership = @contact_group.memberships.build(contact: @contact)

    if @membership.save
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.append("group_members", 
            partial: "contact_groups/member", 
            locals: { member: @contact, group: @contact_group })
        end
        format.html do
          flash[:notice] = l(:notice_contact_added_to_group)
          redirect_to contact_group_path(@contact_group)
        end
      end
    else
      # Handle error, maybe with a turbo_stream alert
      redirect_to contact_group_path(@contact_group), alert: @membership.errors.full_messages.to_sentence
    end
  end
  
  def remove_member
    @contact = Contact.find(params[:contact_id])
    @membership = @contact_group.memberships.find_by!(contact_id: @contact.id)
    @membership.destroy

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove(@contact) }
      format.html do
        flash[:notice] = l(:notice_contact_removed_from_group)
        redirect_to contact_group_path(@contact_group)
      end
    end
  end
  

  private

  def handle_issue_context_creation
    @issue = Issue.find(params.dig(:contact_group, :issue_id))
    @contact_group.project = @issue.project # Associate group with the issue's project

    # Capture the contacts that will be part of the group BEFORE the transaction
    contacts_to_group = @issue.contacts.to_a

    if @contact_group.save
      ActiveRecord::Base.transaction do
        # Associate contacts with the new group
        @contact_group.contacts = contacts_to_group

        # Create the new link for the group
        @issue.contact_issue_links.create!(contact_group: @contact_group)

        # Destroy the old individual links
        @issue.contact_issue_links.where(contact_id: contacts_to_group.map(&:id)).destroy_all
      end

      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("save_group_form_wrapper", ""),
            turbo_stream.replace("issue_contact_links", partial: "issues/contact_issue_link", collection: @issue.reload.contact_issue_links, as: :contact_issue_link),
            turbo_stream.update("issue_contacts_counter", html: @issue.reload.contact_issue_links.count)
          ]
        end
        format.html { redirect_to @issue, notice: l(:notice_contact_group_created_from_issue) }
      end
    else
      # Handle validation errors
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("save_group_form_wrapper") do
            render_to_string partial: "issues/save_group_form", locals: { issue: @issue, contact_group: @contact_group }
          end
        end
        format.html { redirect_to @issue, alert: @contact_group.errors.full_messages.to_sentence }
      end
    end
  end

  def handle_standard_creation
    if @contact_group.save
      respond_to do |format|
        format.html {
          flash[:notice] = l(:notice_contact_group_created)
          redirect_to contact_group_path(@contact_group)
        }
        format.api { render action: 'show', status: :created }
      end
    else
      respond_to do |format|
        format.html { render action: 'new' }
        format.api { render_validation_errors(@contact_group) }
      end
    end
  end
  
  def find_contact_group
    @contact_group = ContactGroup.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end