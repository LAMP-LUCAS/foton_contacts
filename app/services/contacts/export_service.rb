# frozen_string_literal: true

class Contacts::ExportService
  def self.call(contacts, format)
    new(contacts, format).call
  end

  def initialize(contacts, format)
    @contacts = contacts
    @format = format
  end

  def call
    case @format
    when 'csv'
      Contacts::Exporters::CsvSerializer.call(@contacts)
    when 'vcf'
      Contacts::Exporters::VcardSerializer.call(@contacts)
    else
      raise ArgumentError, "Unknown format: #{@format}"
    end
  end
end
