class ContactsController < ApplicationController
  before_action :require_login
  before_action :find_contact, only: [:show, :edit, :update, :destroy, :career_history, :employees_list, :groups, :tasks, :history, :analytics, :show_edit]
  before_action :authorize_global, only: [:index, :show, :new, :create]
  before_action :authorize_edit, only: [:edit, :update, :destroy, :show_edit]
  
  helper :journals
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
        label: :label_contact_employments
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
  
  def edit
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def show_edit
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end
  
  def new
    @contact = Contact.new(author: User.current, contact_type: params[:type])
    @contact.employments_as_person.build if @contact.person?
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def create
    @contact = Contact.new(contact_params.merge(author: User.current))
    
    respond_to do |format|
      if @contact.save
        format.html { redirect_to contacts_path, notice: l(:notice_contact_created) }
        format.turbo_stream
        format.api { render action: 'show', status: :created, location: contact_url(@contact) }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream { render :new, status: :unprocessable_entity }
        format.api { render_validation_errors(@contact) }
      end
    end
  end
  
  def update
    if @contact.update(contact_params)
      respond_to do |format|
        format.html { redirect_to contacts_path, notice: l(:notice_successful_update) }
        format.turbo_stream
        format.api { render_api_ok }
      end
    else
      respond_to do |format|
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream { render :edit, status: :unprocessable_entity }
        format.api { render_validation_errors(@contact) }
      end
    end
  end
  
  def destroy
    @contact.destroy
    respond_to do |format|
      format.html do
        flash[:notice] = l(:notice_contact_deleted)
        redirect_to contacts_path
      end
      format.turbo_stream 
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
    # Data for person contact
    if @contact.person?
      @tasks_count = @contact.issues.count
      @groups_count = @contact.contact_groups.count
      @companies_count = @contact.employments_as_person.count
    end

    # Data for company contact
    if @contact.company?
      @linked_contacts_count = @contact.employees.count
      # Simple interpretation of turnover: count of employments with an end_date
      @turnover_count = @contact.employments_as_company.where.not(end_date: nil).count
    end

    respond_to do |format|
      format.html { render partial: 'contacts/analytics_modal', locals: { contact: @contact } }
      format.turbo_stream { render turbo_stream: turbo_stream.update("modal", partial: "contacts/analytics_modal", locals: { contact: @contact }) }
    end
  end

  def career_history
    @contact_employments = @contact.employments_as_person.includes(:company)
    @employment = @contact.employments_as_person.new
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

  def new_employment_field
    respond_to do |format|
      format.turbo_stream
    end
  end

  def close_modal
    
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove("modal") }
      format.html { redirect_to contacts_path }
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

  def contact_params
    params.require(:contact).permit(
      :name,
      :email,
      :phone,
      :address,
      :contact_type,
      #:status,
      :is_private,
      :project_id,
      :description,
      employments_as_person_attributes: [:id, :company_id, :position, :status, :start_date, :end_date, :_destroy]
    )
  end
end