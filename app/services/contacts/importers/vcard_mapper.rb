# frozen_string_literal: true

class Contacts::Importers::VcardMapper
  def initialize(file)
    @file = file
  end

  def each_contact
    # Vcardigan can parse a file with multiple vCards
    ::VCardigan.parse(@file.read).each do |vcard|
      contact_data = to_contact_data(vcard)
      yield contact_data if block_given?
    end
  end

  private

  def to_contact_data(vcard)
    {
      name: vcard.fullname.first&.value,
      contact_type: 'person', # Assuming all are persons
      status: 'active',
      emails_attributes: build_emails(vcard),
      phones_attributes: build_phones(vcard),
      # employments_as_person_attributes: build_employments(vcard),
      # contact_groups: build_groups(vcard)
    }
  end

  def build_emails(vcard)
    vcard.email.map.with_index do |email_field, index|
      { email: email_field.value, is_primary: index.zero? }
    end
  end

  def build_phones(vcard)
    vcard.tel.map.with_index do |phone_field, index|
      { phone: phone_field.value, is_primary: index.zero? }
    end
  end

  # def build_employments(vcard)
  #   # ... logic to handle ORG and TITLE
  # end

  # def build_groups(vcard)
  #   # ... logic to handle CATEGORIES
  # end
end
