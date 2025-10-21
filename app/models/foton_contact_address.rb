class FotonContactAddress < ActiveRecord::Base
  belongs_to :contact, class_name: 'FotonContact'
  validates :address, presence: true
end
