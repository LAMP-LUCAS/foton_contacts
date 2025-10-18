require File.expand_path('../../test_helper', __FILE__)

class FotonContactAddressTest < ActiveSupport::TestCase
  def setup
    @contact = FotonContact.create!(name: 'Test Contact', contact_type: 'person', status: 'active')
  end

  def test_create_valid_address
    address = @contact.addresses.create(address: '123 Main St')
    assert address.valid?
    assert_equal '123 Main St', address.address
  end

  def test_address_must_be_present
    address = @contact.addresses.create(address: '')
    assert !address.valid?
    assert address.errors[:address].present?
  end

  def test_is_primary_default_value
    address = @contact.addresses.create(address: '123 Main St')
    assert_equal false, address.is_primary
  end

  def test_belongs_to_foton_contact
    address = @contact.addresses.create(address: '123 Main St')
    assert_equal @contact, address.contact
  end
end