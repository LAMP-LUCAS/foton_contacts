# frozen_string_literal: true

class DataQualityIgnore < ActiveRecord::Base
  before_save :order_contact_ids

  private

  def order_contact_ids
    self.contact_a_id, self.contact_b_id = [self.contact_a_id, self.contact_b_id].sort
  end
end
