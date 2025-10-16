class ContactsController < ApplicationController
  helper FotonContactsLinkHelper
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
    @quality_data = Analytics::DataQualityQuery.calculate
    @filter_params = params.permit(:search, :contact_type, :status)

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
        label: :label_details_plural
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
    @contact_groups = @contact.contact_groups.visible(User.current)
    
    respond_to do |format|
      format.html { render partial: 'contacts/show_tabs/groups', locals: { contact_groups: @contact_groups } }
      format.api
    end
  end
  
  def tasks
    # Find issue IDs linked directly to the contact
    direct_issue_ids = @contact.issue_ids

    # Find issue IDs linked to the groups the contact is a member of
    group_issue_ids = Issue.joins(:contact_issue_links)
                           .where(contact_issue_links: { contact_group_id: @contact.contact_group_ids })
                           .pluck(:id)

    # Combine, uniq and fetch visible issues
    all_issue_ids = (direct_issue_ids + group_issue_ids).uniq
    @issues = Issue.where(id: all_issue_ids).visible.includes(:contact_issue_links)

    render partial: 'contacts/show_tabs/issues', layout: false
  end
  
  def history
    employment_ids = @contact.employments_as_person.pluck(:id)
    if @contact.company?
      employment_ids += @contact.employments_as_company.pluck(:id)
    end
    membership_ids = @contact.contact_group_memberships.pluck(:id)

    # Fetch journals from all sources related to the contact
    @journals = Journal.where(
      "(journalized_type = :contact_type AND journalized_id = :contact_id) OR " \
      "(journalized_type = :employment_type AND journalized_id IN (:employment_ids)) OR " \
      "(journalized_type = :membership_type AND journalized_id IN (:membership_ids))",
      {
        contact_type: 'Contact', contact_id: @contact.id,
        employment_type: 'ContactEmployment', employment_ids: employment_ids.uniq,
        membership_type: 'ContactGroupMembership', membership_ids: membership_ids
      }
    ).includes(:user, :details, :journalized).reorder('created_on DESC')

    render partial: 'contacts/show_tabs/history', layout: false
  end
  
  def analytics
    if @contact.person?
      # IRPA and KPIs
      @irpa_data = Analytics::IrpaCalculator.calculate_for_contact(@contact)

      # Career History
      @employments = @contact.employments_as_person.includes(:company).order(start_date: :desc)

      # Current Workload
      @current_workload = @contact.issues.where.not(status: IssueStatus.where(is_closed: true)).includes(:project, :priority, :status).order(due_date: :asc)

      # Recent Performance (last 5 closed issues)
      @recent_performance_issues = @contact.issues.where(status: IssueStatus.where(is_closed: true)).order(closed_on: :desc).limit(5)
    else
      # Analytics for companies are not yet defined in the mockup
      # We can add company-specific analytics here later.
      @linked_contacts_count = @contact.employees.count
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
    query = params[:q].to_s.strip
    results = []

    if query.present?
      # Search for Contacts (Pessoas)
      persons = Contact.visible(User.current)
                       .where(contact_type: Contact.contact_types[:person])
                       .where('LOWER(name) LIKE LOWER(?)', "%#{query.downcase}%")
                       .limit(5)

      if persons.any?
        results << {
          label: l(:label_foton_contacts_persons),
          options: persons.map { |p| { value: "contact-#{p.id}", text: p.name, type: 'person' } }
        }
      end

      # Search for ContactGroups (Grupos)
      groups = ContactGroup.visible(User.current)
                           .where('LOWER(name) LIKE LOWER(?)', "%#{query.downcase}%")
                           .limit(5)

      if groups.any?
        results << {
          label: l(:label_foton_contacts_groups),
          options: groups.map { |g| { value: "group-#{g.id}", text: g.name, type: 'group' } }
        }
      end
    end

    respond_to do |format|
      format.json { render json: results }
    end
  end

  def search_links
    query = params[:q].to_s.strip
    @issue = Issue.find(params[:issue_id])

    if query.blank?
      @contacts = Contact.visible(User.current)
                         .where(contact_type: :person)
                         .limit(10)
      @groups = ContactGroup.visible(User.current)
                            .limit(5)
    else
      @contacts = Contact.visible(User.current)
                         .where(contact_type: :person)
                         .where('LOWER(name) LIKE LOWER(?)', "%#{query}%")
                         .limit(10)

      @groups = ContactGroup.visible(User.current)
                            .where('LOWER(name) LIKE LOWER(?)', "%#{query}%")
                            .limit(5)
    end

    if @issue.present?
      existing_contact_ids = @issue.contact_issue_links.where.not(contact_id: nil).pluck(:contact_id)
      existing_group_ids = @issue.contact_issue_links.where.not(contact_group_id: nil).pluck(:contact_group_id)

      if existing_group_ids.any?
        member_ids = ContactGroupMembership.where(contact_group_id: existing_group_ids).pluck(:contact_id)
        existing_contact_ids.concat(member_ids)
      end

      @contacts = @contacts.where.not(id: existing_contact_ids.uniq)
      @groups = @groups.where.not(id: existing_group_ids)
    end

    respond_to do |format|
      format.html { render :search_links }
      format.turbo_stream do
        render turbo_stream: turbo_stream.update('contact_search_results',
                                                 partial: 'issues/search_results',
                                                 locals: { contacts: @contacts, groups: @groups, issue: @issue })
      end
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
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.remove("modal"),
          turbo_stream.append("content", "<turbo-frame id='modal' data-controller='modal'></turbo-frame>")
        ]
      end
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
      :available_hours_per_day,
      employments_as_person_attributes: [:id, :company_id, :position, :status, :start_date, :end_date, :_destroy]
    )
  end
end