class FotonContactPhone < ActiveRecord::Base
  belongs_to :contact, class_name: 'FotonContact'
  validates :phone, presence: true
end
