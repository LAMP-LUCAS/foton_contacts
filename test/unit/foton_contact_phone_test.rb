require File.expand_path('../../test_helper', __FILE__)

class FotonContactPhoneTest < ActiveSupport::TestCase
  def setup
    @contact = FotonContact.create!(name: 'Test Contact', contact_type: 'person', status: 'active')
  end

  def test_create_valid_phone
    phone = @contact.phones.create(phone: '123-456-7890')
    assert phone.valid?
    assert_equal '123-456-7890', phone.phone
  end

  def test_phone_must_be_present
    phone = @contact.phones.create(phone: '')
    assert !phone.valid?
    assert phone.errors[:phone].present?
  end

  def test_is_primary_default_value
    phone = @contact.phones.create(phone: '123-456-7890')
    assert_equal false, phone.is_primary
  end

  def test_belongs_to_foton_contact
    phone = @contact.phones.create(phone: '123-456-7890')
    assert_equal @contact, phone.contact
  end
end