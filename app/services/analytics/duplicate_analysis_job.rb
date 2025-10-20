# frozen_string_literal: true

class Analytics::DuplicateAnalysisJob
  def self.perform(batch_id)
    new(batch_id).perform
  end

  def initialize(batch_id)
    @batch_id = batch_id
    @imported_contacts = ImportedContact.where(import_batch_id: @batch_id)
  end

  def perform
    @imported_contacts.each do |imported_contact|
      find_and_link_duplicate(imported_contact)
    end
  end

  private

  def find_and_link_duplicate(imported_contact)
    # Use a simplified version of the DuplicateFinderService logic
    # In a real app, this could be more complex
    potential_duplicate = nil
    
    if imported_contact.email.present?
      potential_duplicate = FotonContact.joins(:emails).where(foton_contact_emails: { email: imported_contact.email }).first
    end

    if potential_duplicate.nil? && imported_contact.name.present?
      # This is a simple version of the fuzzy search
      potential_duplicate = FotonContact.where("similarity(name, ?) > 0.7", imported_contact.name).first
    end

    if potential_duplicate
      imported_contact.update(potential_duplicate_id: potential_duplicate.id)
    end
  end
end
