class AddWorkloadToContacts < ActiveRecord::Migration[7.1]
  def change
    add_column :contacts, :available_hours_per_day, :float
  end
end
