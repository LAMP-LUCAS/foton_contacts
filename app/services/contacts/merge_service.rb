# frozen_string_literal: true

class Contacts::MergeService
  def self.call(primary_contact, duplicate_contact, attributes_to_keep)
    new(primary_contact, duplicate_contact, attributes_to_keep).call
  end

  def initialize(primary_contact, duplicate_contact, attributes_to_keep)
    @primary_contact = primary_contact
    @duplicate_contact = duplicate_contact
    @attributes_to_keep = attributes_to_keep
  end

  def call
    ActiveRecord::Base.transaction do
      # Separate simple attributes from associations
      simple_attributes = @attributes_to_keep.slice(:name, :description)
      associations = @attributes_to_keep.except(:name, :description)

      # 1. Update primary contact with simple attributes
      @primary_contact.update!(simple_attributes)

      # 2. Handle associations
      process_associations(associations)

      # 3. Re-associate related models from the duplicate
      reassociate_models

      # 4. Destroy the duplicate contact
      @duplicate_contact.destroy!

      @primary_contact # Return the surviving contact
    end
  rescue => e
    Rails.logger.error "Merge failed: #{e.message}"
    false
  end

  private

  def process_associations(associations)
    associations.each do |assoc_name, data|
      next unless data.is_a?(Hash) && data[:present] == '1'

      association = @primary_contact.send(assoc_name)
      association.destroy_all

      value_method = assoc_name.to_s.singularize
      primary_value = data[:primary]

      (data[:values] || []).each do |value|
        association.create!(value_method => value, is_primary: (value == primary_value))
      end
    end
  end

  def reassociate_models
    # Re-associate models that have a direct link to the contact
    [ContactGroupMembership, ContactIssueLink, ContactEmployment].each do |model|
      model.where(contact_id: @duplicate_contact.id).update_all(contact_id: @primary_contact.id)
    end

    # For employments where the contact is the company
    ContactEmployment.where(company_id: @duplicate_contact.id).update_all(company_id: @primary_contact.id)

    # Re-associate attachments
    Attachment.where(container_id: @duplicate_contact.id, container_type: 'FotonContact').update_all(container_id: @primary_contact.id)

    # Re-associate journals
    Journal.where(journalized_id: @duplicate_contact.id, journalized_type: 'FotonContact').update_all(journalized_id: @primary_contact.id)
  end
end
