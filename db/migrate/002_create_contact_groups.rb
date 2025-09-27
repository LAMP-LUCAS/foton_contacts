class CreateContactGroups < ActiveRecord::Migration[5.2]
  def change
    create_table :contact_groups do |t|
      t.string :name, null: false
      t.text :description
      t.integer :group_type, null: false, default: 0 # 0: general, 1: private, 2: system
      t.references :author, foreign_key: { to_table: :users }
      t.references :project
      t.timestamps
    end
  end
end