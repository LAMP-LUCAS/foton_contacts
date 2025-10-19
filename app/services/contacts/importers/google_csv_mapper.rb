# frozen_string_literal: true
require 'csv'

class Contacts::Importers::GoogleCsvMapper
  def initialize(file)
    @file = file
  end

  def each_contact
    # The file is uploaded as a Tempfile, so we can read its path
    CSV.foreach(@file.path, headers: true, col_sep: ',', encoding: 'UTF-8') do |row|
      contact_data = to_contact_data(row)
      yield contact_data if block_given?
    end
  end

  private

  def to_contact_data(row)
    # NOTE: This is a simplified mapping. A real implementation would be more robust.
    {
      name: [row['First Name'], row['Middle Name'], row['Last Name']].compact.join(' '),
      contact_type: 'person', # Assuming all are persons for now
      status: 'active',
      emails_attributes: build_emails(row),
      phones_attributes: build_phones(row),
      # employments_as_person_attributes: build_employments(row),
      # contact_groups: build_groups(row)
    }
  end

  def build_emails(row)
    emails = []
    (1..5).each do |i|
      email_value = row["E-mail #{i} - Value"]
      if email_value.present?
        emails << { email: email_value, is_primary: emails.empty? }
      end
    end
    emails
  end

  def build_phones(row)
    phones = []
    (1..5).each do |i|
      phone_value = row["Phone #{i} - Value"]
      if phone_value.present?
        phones << { phone: phone_value, is_primary: phones.empty? }
      end
    end
    phones
  end

  # def build_employments(row)
  #   # ... logic to handle Organization Name and Title
  # end

  # def build_groups(row)
  #   # ... logic to handle Labels
  # end
end
