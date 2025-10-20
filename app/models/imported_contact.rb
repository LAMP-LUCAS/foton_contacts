# frozen_string_literal: true

class ImportedContact < ActiveRecord::Base
  belongs_to :potential_duplicate, class_name: 'FotonContact', optional: true
end
