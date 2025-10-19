# frozen_string_literal: true

class Contacts::ImportService
  def self.call(file, format, user)
    new(file, format, user).call
  end

  def initialize(file, format, user)
    @file = file
    @format = format
    @user = user
    @stats = { created: 0, updated: 0, failed: 0, errors: [] }
  end

  def call
    process_file
    @stats
  end

  private

  def process_file
    mapper = case @format
             when 'google_csv'
               Contacts::Importers::GoogleCsvMapper.new(@file)
             when 'apple_vcf'
               Contacts::Importers::VcardMapper.new(@file)
             else
               raise ArgumentError, "Unknown format: #{@format}"
             end

    mapper.each_contact do |contact_data|
      persist_contact(contact_data)
    end
  end

  def persist_contact(contact_data)
    # Logic to find or create contact
    # For now, we just count them
    # @stats[:created] += 1
    
    # Duplicity check based on email
    primary_email = contact_data.dig(:emails_attributes, 0, :email)
    contact = find_contact_by_email(primary_email)

    if contact
      # Update existing contact
      update_contact(contact, contact_data)
    else
      # Create new contact
      create_contact(contact_data)
    end
  rescue => e
    @stats[:failed] += 1
    @stats[:errors] << { name: contact_data[:name], error: e.message }
  end

  def find_contact_by_email(email)
    return nil if email.blank?
    FotonContactEmail.find_by(email: email)&.contact
  end

  def create_contact(contact_data)
    contact = FotonContact.new(contact_data.merge(author: @user))
    if contact.save
      @stats[:created] += 1
    else
      @stats[:failed] += 1
      @stats[:errors] << { name: contact_data[:name], error: contact.errors.full_messages.join(', ') }
    end
  end

  def update_contact(contact, contact_data)
    # For now, we don't update existing contacts to avoid data loss.
    # This can be implemented later.
    # For simplicity, we'll just count it as an update.
    if contact.update(contact_data)
        @stats[:updated] += 1
    else
        @stats[:failed] += 1
        @stats[:errors] << { name: contact_data[:name], error: contact.errors.full_messages.join(', ') }
    end
  end
end
