# db/migrate/..._create_contact_employments.rb
class CreateContactEmployments < ActiveRecord::Migration[6.1]
  def change
    create_table :contact_employments do |t|
      t.references :contact, null: false, foreign_key: { to_table: :contacts }
      t.references :company, null: false, foreign_key: { to_table: :contacts }
      t.string :position
      t.date :start_date, default: -> { "CURRENT_DATE" }
      t.date :end_date
      t.timestamps
    end

    add_index :contact_employments, [:contact_id, :company_id], unique: true, where: "end_date IS NULL"
  end
end