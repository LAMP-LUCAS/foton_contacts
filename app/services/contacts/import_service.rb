# frozen_string_literal: true

class Contacts::ImportService
  def self.call(file, format, user)
    new(file, format, user).call
  end

  def initialize(file, format, user)
    @file = file
    @format = format
    @user = user
    @import_batch_id = Time.now.to_i.to_s + SecureRandom.hex(4)
    @stats = { created: 0, failed: 0 }
  end

  def call
    process_file
    { stats: @stats, batch_id: @import_batch_id }
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
      save_to_quarantine(contact_data)
    end
  end

  def save_to_quarantine(contact_data)
    imported_contact = ImportedContact.new(
      import_batch_id: @import_batch_id,
      raw_data: contact_data.to_json,
      name: contact_data[:name],
      email: contact_data.dig(:emails_attributes, 0, :email),
      phone: contact_data.dig(:phones_attributes, 0, :phone),
      description: contact_data[:description]
    )
    if imported_contact.save
      @stats[:created] += 1
    else
      @stats[:failed] += 1
    end
  end
end
