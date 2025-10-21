require File.expand_path('../../test_helper', __FILE__)

class FotonContactTest < ActiveSupport::TestCase
  include FotonContacts::TestHelper
  
  def setup
    setup_contact_test
  end
  
  def test_create_person
    contact = create_contact
    assert_equal 'person', contact.contact_type
    assert contact.person?
    assert !contact.company?
  end
  
  def test_create_company
    contact = create_company
    assert_equal 'company', contact.contact_type
    assert contact.company?
    assert !contact.person?
  end
  
  def test_validates_presence_of_name
    contact = FotonContact.new(contact_type: 'person', status: 'active')
    assert !contact.valid?
    assert contact.errors[:name].present?
  end
  
  def test_validates_contact_type
    contact = FotonContact.new(name: 'Test', status: 'active', contact_type: 'invalid')
    assert !contact.valid?
    assert contact.errors[:contact_type].present?
  end
  

  
  def test_scope_persons
    person = create_contact
    company = create_company
    
    persons = FotonContact.persons
    assert_includes persons, person
    assert_not_includes persons, company
  end
  
  def test_scope_companies
    person = create_contact
    company = create_company
    
    companies = FotonContact.companies
    assert_includes companies, company
    assert_not_includes companies, person
  end
  
  def test_scope_active
    active = create_contact
    inactive = create_contact(status: 'inactive')
    
    actives = FotonContact.active
    assert_includes actives, active
    assert_not_includes actives, inactive
  end
  
  def test_scope_visible
    admin = User.generate!(admin: true)
    regular_user = User.generate!
    
    public_contact = create_contact(is_private: false)
    private_contact = create_contact(is_private: true)
    my_private_contact = create_contact(is_private: true, author: regular_user)
    
    User.current = admin
    visible_to_admin = FotonContact.visible(admin)
    assert_includes visible_to_admin, public_contact
    assert_includes visible_to_admin, private_contact
    assert_includes visible_to_admin, my_private_contact
    
    User.current = regular_user
    visible_to_user = FotonContact.visible(regular_user)
    assert_includes visible_to_user, public_contact
    assert_not_includes visible_to_user, private_contact
    assert_includes visible_to_user, my_private_contact
  end
  
  def test_contact_has_many_emails
    contact = create_contact
    assert_respond_to contact, :emails
    assert_difference 'FotonContactEmail.count', 1 do
      contact.emails.create(email: 'test@example.com')
    end
  end

  def test_contact_has_many_phones
    contact = create_contact
    assert_respond_to contact, :phones
    assert_difference 'FotonContactPhone.count', 1 do
      contact.phones.create(phone: '123-456-7890')
    end
  end

  def test_contact_has_many_addresses
    contact = create_contact
    assert_respond_to contact, :addresses
    assert_difference 'FotonContactAddress.count', 1 do
      contact.addresses.create(address: '123 Main St')
    end
  end

  def test_accepts_nested_attributes_for_emails
    contact = FotonContact.create!(
      name: 'Test Contact',
      contact_type: 'person',
      status: 'active',
      emails_attributes: [{ email: 'nested@example.com', is_primary: true }]
    )
    assert_equal 1, contact.emails.count
    assert_equal 'nested@example.com', contact.emails.first.email
    assert contact.emails.first.is_primary
  end

  def test_accepts_nested_attributes_for_phones
    contact = FotonContact.create!(
      name: 'Test Contact',
      contact_type: 'person',
      status: 'active',
      phones_attributes: [{ phone: '111-222-3333', is_primary: true }]
    )
    assert_equal 1, contact.phones.count
    assert_equal '111-222-3333', contact.phones.first.phone
    assert contact.phones.first.is_primary
  end

  def test_accepts_nested_attributes_for_addresses
    contact = FotonContact.create!(
      name: 'Test Contact',
      contact_type: 'person',
      status: 'active',
      addresses_attributes: [{ address: '456 Oak Ave', is_primary: true }]
    )
    assert_equal 1, contact.addresses.count
    assert_equal '456 Oak Ave', contact.addresses.first.address
    assert contact.addresses.first.is_primary
  end

  def test_delegated_email_method
    contact = create_contact
    contact.emails.create!(email: 'primary@example.com', is_primary: true)
    contact.emails.create!(email: 'secondary@example.com', is_primary: false)
    assert_equal 'primary@example.com', contact.email

    contact_no_primary = create_contact
    contact_no_primary.emails.create!(email: 'first@example.com', is_primary: false)
    contact_no_primary.emails.create!(email: 'second@example.com', is_primary: false)
    assert_equal 'first@example.com', contact_no_primary.email
  end

  def test_delegated_phone_method
    contact = create_contact
    contact.phones.create!(phone: '111-111-1111', is_primary: true)
    contact.phones.create!(phone: '222-222-2222', is_primary: false)
    assert_equal '111-111-1111', contact.phone

    contact_no_primary = create_contact
    contact_no_primary.phones.create!(phone: '333-333-3333', is_primary: false)
    contact_no_primary.phones.create!(phone: '444-444-4444', is_primary: false)
    assert_equal '333-333-3333', contact_no_primary.phone
  end

  def test_delegated_address_method
    contact = create_contact
    contact.addresses.create!(address: 'Primary Address', is_primary: true)
    contact.addresses.create!(address: 'Secondary Address', is_primary: false)
    assert_equal 'Primary Address', contact.address

    contact_no_primary = create_contact
    contact_no_primary.addresses.create!(address: 'First Address', is_primary: false)
    contact_no_primary.addresses.create!(address: 'Second Address', is_primary: false)
    assert_equal 'First Address', contact_no_primary.address
  def test_company_relationships
    person = create_contact
    company1 = create_company
    company2 = create_company
    
    create_contact_role(person: person, company: company1)
    create_contact_role(person: person, company: company2)
    
    assert_equal 2, person.companies.count
    assert_includes person.companies, company1
    assert_includes person.companies, company2
  end
  
  def test_employee_relationships
    company = create_company
    person1 = create_contact
    person2 = create_contact
    
    create_contact_role(person: person1, company: company)
    create_contact_role(person: person2, company: company)
    
    assert_equal 2, company.employees.count
    assert_includes company.employees, person1
    assert_includes company.employees, person2
  end
end