# frozen_string_literal: true

class ImportedContact < ActiveRecord::Base
  belongs_to :potential_duplicate, class_name: 'FotonContact', optional: true
  
  validates :name, presence: true
  validates :import_batch_id, presence: true
  
  enum :status, {
    pending_review: 'pending_review',
    created: 'created', 
    ignored: 'ignored'
  }, default: 'pending_review'
  
  serialize :additional_emails, type: Array, coder: JSON
  serialize :additional_phones, type: Array, coder: JSON
  
  # Scopes úteis
  scope :pending_review, -> { where(status: 'pending_review') }
  scope :with_potential_duplicates, -> { where.not(potential_duplicate_id: nil) }
  scope :without_potential_duplicates, -> { where(potential_duplicate_id: nil) }
  
  # Método para obter todos os emails
  def all_emails
    [email, *additional_emails].compact.uniq
  end
  
  # Método para obter todos os telefones
  def all_phones
    [phone, *additional_phones].compact.uniq
  end
  
  # Método para conversão para FotonContact
  def to_foton_contact_attributes
    {
      name: name,
      description: description,
      contact_type: contact_type,
      emails_attributes: build_emails_attributes,
      phones_attributes: build_phones_attributes
    }
  end
  
  private
  
  def build_emails_attributes
    all_emails.map.with_index do |email, index|
      { email: email, is_primary: index.zero? }
    end
  end
  
  def build_phones_attributes
    all_phones.map.with_index do |phone, index|
      { phone: phone, is_primary: index.zero? }
    end
  end
end