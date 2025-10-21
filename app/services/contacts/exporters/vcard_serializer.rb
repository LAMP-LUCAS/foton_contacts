# frozen_string_literal: true

class Contacts::Exporters::VcardSerializer
  def self.call(contacts)
    new(contacts).call
  end

  def initialize(contacts)
    @contacts = contacts
  end

  def call
    vcard_string = ""
    @contacts.each do |contact|
      vcard_string += serialize_contact(contact)
    end
    vcard_string
  end

  private

  def serialize_contact(contact)
    vcard = ::VCardigan.create
    vcard.fullname contact.name
    vcard.n contact.name, nil, nil, nil, nil # Simplified name

    contact.emails.each do |email|
      vcard.email email.email, type: 'work' # Simplified type
    end

    contact.phones.each do |phone|
      vcard.tel phone.phone, type: 'work' # Simplified type
    end

    if contact.person? && contact.employments_as_person.any?
      employment = contact.employments_as_person.first
      vcard.org employment.company.name
      vcard.title employment.position
    end

    if contact.contact_groups.any?
      vcard.categories contact.contact_groups.map(&:name)
    end

    vcard.to_s
  end
end
