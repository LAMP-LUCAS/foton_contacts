# frozen_string_literal: true
require 'csv'

class Contacts::Exporters::CsvSerializer
  def self.call(contacts)
    new(contacts).call
  end

  def initialize(contacts)
    @contacts = contacts
  end

  def call
    CSV.generate(col_sep: ',') do |csv|
      csv << headers
      @contacts.each do |contact|
        csv << serialize_contact(contact)
      end
    end
  end

  private

  def headers
    # Based on Google CSV format
    [
      'Name', 'Given Name', 'Family Name',
      'Group Membership',
      'E-mail 1 - Type', 'E-mail 1 - Value',
      'E-mail 2 - Type', 'E-mail 2 - Value',
      'Phone 1 - Type', 'Phone 1 - Value',
      'Phone 2 - Type', 'Phone 2 - Value',
      'Organization 1 - Name', 'Organization 1 - Title'
    ]
  end

  def serialize_contact(contact)
    row = []
    row += [contact.name, contact.name, ''] # Simplified name parsing
    row += [contact.contact_groups.map(&:name).join(' ::: ')]

    # Emails
    contact.emails.limit(2).each do |email|
      row += ['Work', email.email] # Simplified type
    end
    row += [nil, nil] * [0, 2 - contact.emails.count].max # Fill empty

    # Phones
    contact.phones.limit(2).each do |phone|
      row += ['Work', phone.phone] # Simplified type
    end
    row += [nil, nil] * [0, 2 - contact.phones.count].max # Fill empty

    # Organization
    if contact.person? && contact.employments_as_person.any?
      employment = contact.employments_as_person.first
      row += [employment.company.name, employment.position]
    else
      row += [nil, nil]
    end

    row
  end
end
