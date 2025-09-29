'''
Controlador principal para gerenciar contatos (pessoas e empresas).
Oferece operações completas de CRUD, importação, exportação e visualizações secundárias.

Classe: ContactsController

  Descrição:
    Controlador principal responsável pela gestão de contatos no sistema, incluindo pessoas e empresas. Oferece funcionalidades completas de listagem, criação, edição, exclusão, importação, exportação e visualizações detalhadas.

  Ações:

    index: Lista contatos com filtros, ordenação e paginação; suporta HTML, API e CSV.

    show: Exibe detalhes do contato, incluindo cargos, grupos e issues relacionadas; suporta vCard.

    new: Inicializa um novo contato.

    create: Cria um novo contato.

    edit: Prepara a edição de um contato.

    update: Atualiza os dados do contato.

    destroy: Exclui o contato.

    history: Exibe o histórico de alterações (journals).

    analytics: Fornece dados analíticos (se habilitado).

    search: Busca contatos para sugestão em campos de busca.

    autocomplete: Retorna sugestões para autocompletar.

    import: Processa importação de contatos via arquivo CSV.

  Filtros:

    require_login: Exige autenticação.

    find_contact: Carrega o contato a partir de params[:id].

    authorize_global: Para ações globais como listar e criar.

    authorize_edit: Para ações de edição e exclusão.

    Helpers incluídos:

    sort_helper: Para ordenação de listas.

    custom_fields_helper: Para campos personalizados.

    attachments_helper e issues_helper: Para anexos e issues.

    chartkick_helper: Para gráficos (se a gem estiver instalada).



'''


class ContactsController < ApplicationController
  before_action :require_login
  before_action :find_contact, only: [:show, :edit, :update, :destroy, :career_history, :employees_list, :groups, :tasks, :history, :analytics]
  before_action :authorize_global, only: [:index, :show, :new, :create]
  before_action :authorize_edit, only: [:edit, :update, :destroy]
  
  helper :sort
  include SortHelper
  helper :custom_fields
  include CustomFieldsHelper
  helper :attachments, :issues
  include AttachmentsHelper, IssuesHelper
  
  # Carrega o helper do Chartkick apenas se a gem estiver definida
  helper Chartkick::Helper if Redmine::Plugin.installed?(:chartkick)
  
  def index
    sort_init 'name', 'asc'
    sort_update %w(name status created_at)

    scope = Contact.visible(User.current)
                  .includes(:author, :project)
                  
    # Filtros
    scope = scope.where(contact_type: params[:contact_type]) if params[:contact_type].present?
    scope = scope.where(status: params[:status]) if params[:status].present?
    scope = scope.where(project_id: params[:project_id]) if params[:project_id].present?
    scope = scope.where(is_private: params[:is_private] == '1') if params[:is_private].present?
    
    if params[:search].present?
      search = "%#{params[:search].downcase}%"
      scope = scope.where(
        'LOWER(name) LIKE ? OR LOWER(email) LIKE ? OR LOWER(description) LIKE ?',
        search, search, search
      )
    end
    
    scope = scope.order(sort_clause)

    @contact_count = scope.count
    @contact_pages = Paginator.new @contact_count, per_page_option, params['page']
    @contacts = scope.limit(@contact_pages.per_page).offset(@contact_pages.offset)
    
    respond_to do |format|
      format.html
      format.api
      format.csv { send_data(Contact.contacts_to_csv(@contacts), filename: 'contacts.csv') }
    end
  end
  
  def show
    @custom_values = @contact.custom_values

    # Define tabs for the view
    @tabs = [
      {
        name: 'details',
        partial: 'contacts/show_tabs/details',
        label: :label_details
      }
    ]

    if @contact.person?
      @tabs << {
        name: 'career_history',
        partial: 'contacts/show_tabs/career_history_frame',
        label: :label_professional_links
      }
    else # Company
      @tabs << {
        name: 'employees_list',
        partial: 'contacts/show_tabs/employees_list_frame',
        label: :label_employees
      }
    end

    @tabs += [
      {
        name: 'groups',
        partial: 'contacts/show_tabs/groups_frame',
        label: :label_groups
      },
      {
        name: 'tasks',
        partial: 'contacts/show_tabs/issues_frame',
        label: :label_issues
      },
      {
        name: 'history',
        partial: 'contacts/show_tabs/history_frame',
        label: :label_history
      }
    ]

    respond_to do |format|
      format.html
      format.api
      format.vcf { send_data(@contact.to_vcard, filename: "#{@contact.name}.vcf") }
    end
  end
  
  def new
    @contact = Contact.new(author: User.current, contact_type: params[:type])
    render layout: false
  end

  def create
    @contact = Contact.new(author: User.current)
    @contact.safe_attributes = params[:contact]
    
    respond_to do |format|
      if @contact.save
        format.html { redirect_to contacts_path, notice: l(:notice_contact_created) }
        format.turbo_stream
        format.api { render action: 'show', status: :created, location: contact_url(@contact) }
      else
        format.html { render :new, status: :unprocessable_entity, layout: false }
        format.api { render_validation_errors(@contact) }
      end
    end
  end
  
  def edit
    render layout: false
  end
  
  def update
    @contact.safe_attributes = params[:contact]
    
    respond_to do |format|
      if @contact.save
        format.html { redirect_to contacts_path, notice: l(:notice_successful_update) }
        format.turbo_stream
        format.api { render_api_ok }
      else
        format.html { render :edit, status: :unprocessable_entity, layout: false }
        format.api { render_validation_errors(@contact) }
      end
    end
  end
  
  def destroy
    @contact.destroy
    respond_to do |format|
      format.html {
        flash[:notice] = l(:notice_contact_deleted)
        redirect_to contacts_path
      }
      format.api { render_api_ok }
    end
  end
  
  def groups
    @contact_groups = @contact.contact_groups
    render partial: 'contacts/show_tabs/groups', layout: false
  end
  
  def tasks
    @issues = @contact.issues.visible
    render partial: 'contacts/show_tabs/issues', layout: false
  end
  
  def history
    @journals = @contact.journals.includes(:user).reorder('created_on DESC')
    render partial: 'contacts/show_tabs/history', layout: false
  end
  
  def analytics
    respond_to do |format|
      format.js # Deixa o Rails renderizar analytics.js.erb por convenção
    end
  end

  def career_history
    @contact_employments = @contact.employments_as_person.includes(:company)
    render partial: 'contacts/show_tabs/career_history', layout: false
  end

  def employees_list
    @employees = @contact.employees.includes(:person)
    render partial: 'contacts/show_tabs/employees_list', layout: false
  end
  
  def search
    @contacts = Contact.visible(User.current)
                      .where('LOWER(name) LIKE LOWER(?)', "%#{params[:q]}%")
                      .limit(10)
    
    respond_to do |format|
      format.json { render json: @contacts.map { |c| { id: c.id, text: c.name } } }
    end
  end
  
  def autocomplete
    @contacts = Contact.visible(User.current)
                      .where('LOWER(name) LIKE LOWER(?)', "%#{params[:q]}%")
                      .limit(10)
    render layout: false
  end
  
  def import
    if request.post? && params[:file].present?
      count = Contact.import_csv(params[:file], User.current)
      flash[:notice] = l(:notice_contacts_imported, count: count)
      redirect_to contacts_path
    end
  end

  def close_modal
    # By convention, this will render close_modal.turbo_stream.erb
  end
  
  private
  
  def find_contact
    @contact = Contact.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end
  
  def authorize_edit
    unless @contact.visible?(User.current)
      deny_access
      return false
    end
    true
  end

  def contact_params
    params.require(:contact).permit(
      :first_name, :last_name, :email, :phone, :mobile, :notes, :active, :contact_type,
      employments_as_person_attributes: [
        :id, :company_id, :position, :start_date, :end_date, :_destroy
      ]
    )
  end

end