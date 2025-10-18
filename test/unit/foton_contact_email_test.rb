require File.expand_path('../../test_helper', __FILE__)

class FotonContactEmailTest < ActiveSupport::TestCase
  def setup
    @contact = FotonContact.create!(name: 'Test Contact', contact_type: 'person', status: 'active')
  end

  def test_create_valid_email
    email = @contact.emails.create(email: 'test@example.com')
    assert email.valid?
    assert_equal 'test@example.com', email.email
  end

  def test_email_must_be_present
    email = @contact.emails.create(email: '')
    assert !email.valid?
    assert email.errors[:email].present?
  end

  def test_email_format_validation
    email = @contact.emails.create(email: 'invalid-email')
    assert !email.valid?
    assert email.errors[:email].present?

    email.email = 'valid@example.com'
    assert email.valid?
  end

  def test_is_primary_default_value
    email = @contact.emails.create(email: 'test@example.com')
    assert_equal false, email.is_primary
  end

  def test_belongs_to_foton_contact
    email = @contact.emails.create(email: 'test@example.com')
    assert_equal @contact, email.contact
  end
end