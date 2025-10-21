class FotonContactEmail < ActiveRecord::Base
  belongs_to :contact, class_name: 'FotonContact'
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
end
