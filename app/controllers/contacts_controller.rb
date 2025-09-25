class ContactsController < ApplicationController
  before_action :require_login
  before_action :find_contact, only: [:show, :edit, :update, :destroy, :roles, :groups, :tasks, :history, :analytics]
  before_action :authorize_global, only: [:index, :show, :new, :create]
  before_action :authorize_edit, only: [:edit, :update, :destroy]
  
  helper :sort
  include SortHelper
  helper :custom_fields
  include CustomFieldsHelper
  helper :attachments
  include AttachmentsHelper
  
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
    @roles = @contact.roles.includes(:company)
    @groups = @contact.groups.visible(User.current)
    @issues = @contact.issues.visible(User.current)
    
    respond_to do |format|
      format.html
      format.api
      format.vcf { send_data(@contact.to_vcard, filename: "#{@contact.name}.vcf") }
    end
  end
  
  def new
    @contact = Contact.new(author: User.current)
    @contact.safe_attributes = params[:contact]
  end

  def create
    @contact = Contact.new(author: User.current)
    @contact.safe_attributes = params[:contact]
    
    if @contact.save
      respond_to do |format|
        format.html {
          flash[:notice] = l(:notice_contact_created)
          redirect_to contact_path(@contact)
        }
        format.js {
          flash[:notice] = l(:notice_contact_created)
          render js: "window.location.reload();"
        }
        format.api { render action: 'show', status: :created, location: contact_url(@contact) }
      end
    else
      respond_to do |format|
        format.html { render action: 'new' }
        format.js { render partial: 'new_form', layout: false }
        format.api { render_validation_errors(@contact) }
      end
    end
  end
  
  def edit
    if request.xhr?
      render partial: 'form', locals: { f: ActionView::Helpers::FormBuilder.new(:contact, @contact, self, {}) }, layout: false
    end
  end
  
  def update
    @contact.safe_attributes = params[:contact]
    
    if @contact.save
      respond_to do |format|
        format.html {
          flash[:notice] = l(:notice_contact_updated)
          redirect_to contact_path(@contact)
        }
        format.api { render_api_ok }
      end
    else
      respond_to do |format|
        format.html { render action: 'edit' }
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
  
  def roles
    @roles = @contact.roles.includes(:company)
  end
  
  def groups
    @groups = @contact.groups.visible(User.current)
  end
  
  def tasks
    @issues = @contact.issues.visible(User.current)
  end
  
  def history
    @journals = @contact.journals.includes(:user).reorder('created_on DESC')
  end
  
  def analytics
    respond_to do |format|
      format.html { render partial: 'contacts/analysis/modal', locals: { contact: @contact }, layout: false }
    end
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
end