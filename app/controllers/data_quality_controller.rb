# frozen_string_literal: true

class DataQualityController < ApplicationController
  before_action :require_login
  before_action :authorize_global

  def index
    @active_tab = params[:tab] || 'database_duplicates'
    @pending_imports = []
    @pairs = []

    if @active_tab == 'import_review'
      @conflicting_imports = ImportedContact.where(status: 'pending_review').where.not(potential_duplicate_id: nil).order(created_at: :desc)
      @safe_imports = ImportedContact.where(status: 'pending_review', potential_duplicate_id: nil).order(created_at: :desc)
    end
  end

  def scan
    @pairs = Analytics::DuplicateFinderService.call
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.update('duplicate_results', 
                                                 partial: 'data_quality/duplicate_pairs', 
                                                 locals: { pairs: @pairs })
      end
    end
  end

  def show
    if params[:imported_id]
      @contact1 = FotonContact.find(params[:id])
      @imported_contact = ImportedContact.find(params[:imported_id])
      @contact2 = build_contact_from_imported(@imported_contact)
    else
      @contact1 = FotonContact.find(params[:id])
      @contact2 = FotonContact.find(params[:other_id])
    end

    if @contact2.updated_at > @contact1.updated_at
      @contact1, @contact2 = @contact2, @contact1
    end
  end

  def preview
    @contact1 = FotonContact.find(params[:id])
    @contact2 = FotonContact.find(params[:other_id])
    
    attributes = params.fetch(:attributes, {}).permit!
    @merged_contact = FotonContact.new

    @merged_contact.name = attributes[:name] || @contact1.name
    @merged_contact.description = attributes[:description] || @contact1.description

    # Build has_many associations in memory
    if attributes[:emails].is_a?(Hash)
      (attributes.dig(:emails, :values) || []).each do |email_value|
        is_primary = (email_value == attributes.dig(:emails, :primary))
        @merged_contact.emails.build(email: email_value, is_primary: is_primary)
      end
    end

    if attributes[:phones].is_a?(Hash)
      (attributes.dig(:phones, :values) || []).each do |phone_value|
        is_primary = (phone_value == attributes.dig(:phones, :primary))
        @merged_contact.phones.build(phone: phone_value, is_primary: is_primary)
      end
    end

    @final_attributes = attributes.to_h
    render partial: 'data_quality/preview'
  end

  def merge
    if params[:id] == params[:other_id]
      redirect_to success_data_quality_path(id: params[:id]), notice: l(:notice_merge_skipped_same_contact)
      return
    end

    @contact1 = FotonContact.find(params[:id])
    @contact2 = FotonContact.find(params[:other_id])
    
    attributes_to_keep = JSON.parse(params[:attributes]).with_indifferent_access
    surviving_contact = Contacts::MergeService.call(@contact1, @contact2, attributes_to_keep)

    if surviving_contact
      redirect_to success_data_quality_path(id: surviving_contact.id), notice: l(:notice_merge_successful)
    else
      redirect_to data_quality_path(id: @contact1.id, other_id: @contact2.id), flash: { error: l(:error_merge_failed) }
    end
  end

  def success
    @contact = FotonContact.find(params[:id])
  end

  def batch_action
    pair_ids = params[:pair_ids]
    action = params[:batch_action]

    if pair_ids.blank?
      redirect_to data_quality_index_path, flash: { error: l(:error_no_pairs_selected) }
      return
    end

    if action == 'ignore'
      ignored_count = 0
      pair_ids.each do |pair_str|
        contact_a_id, contact_b_id = pair_str.split('-').map(&:to_i)
        DataQualityIgnore.create(contact_a_id: contact_a_id, contact_b_id: contact_b_id)
        ignored_count += 1
      end
      redirect_to data_quality_index_path, notice: l(:notice_pairs_ignored, count: ignored_count)
    elsif action == 'merge_recommended'
      merged_count = 0
      error_count = 0
      pair_ids.each do |pair_str|
        contact_ids = pair_str.split('-').map(&:to_i)
        contact1 = FotonContact.find(contact_ids[0])
        contact2 = FotonContact.find(contact_ids[1])

        # Determine the recommended (primary) and the duplicate
        primary_contact, duplicate_contact = [contact1, contact2].sort_by(&:updated_at).reverse

        # For batch merge, we assume we want to keep all data from the primary contact
        attributes_to_keep = {
          name: primary_contact.name,
          description: primary_contact.description,
          emails: { values: primary_contact.emails.map(&:email) },
          phones: { values: primary_contact.phones.map(&:phone) }
        }

        if Contacts::MergeService.call(primary_contact, duplicate_contact, attributes_to_keep)
          merged_count += 1
        else
          error_count += 1
        end
      end
      flash[:notice] = l(:notice_batch_merge_completed, count: merged_count)
      flash[:error] = l(:error_batch_merge_failed, count: error_count) if error_count > 0
      redirect_to data_quality_index_path
    end
  end

  def batch_process_imports
    ids = params[:imported_ids]
    action = params[:batch_action]

    if ids.blank?
      redirect_to data_quality_index_path(tab: 'import_review'), flash: { error: l(:error_no_imports_selected) }
      return
    end

    if action == 'create'
      created_count = 0
      ImportedContact.where(id: ids).each do |ic|
        contact_attributes = {
          name: ic.name,
          description: ic.description,
          author: User.current,
          emails_attributes: [{ email: ic.email, is_primary: true }],
          phones_attributes: [{ phone: ic.phone, is_primary: true }]
        }
        contact = FotonContact.new(contact_attributes)
        if contact.save
          ic.update(status: 'created')
          created_count += 1
        end
      end
      redirect_to data_quality_index_path(tab: 'import_review'), notice: l(:notice_imports_created, count: created_count)
    elsif action == 'delete'
      deleted_count = ImportedContact.where(id: ids).delete_all
      redirect_to data_quality_index_path(tab: 'import_review'), notice: l(:notice_imports_deleted, count: deleted_count)
    end
  end

  private

  def authorize_global
    unless User.current.allowed_to_globally?(:manage_contacts)
      deny_access
    end
  end

  def build_contact_from_imported(imported_contact)
    FotonContact.new(
      name: imported_contact.name,
      description: imported_contact.description,
      emails: [FotonContactEmail.new(email: imported_contact.email, is_primary: true)],
      phones: [FotonContactPhone.new(phone: imported_contact.phone, is_primary: true)]
    )
  end
end