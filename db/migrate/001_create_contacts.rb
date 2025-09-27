class CreateContacts < ActiveRecord::Migration[5.2]
  def change
    create_table :contacts do |t|
      t.string :name, null: false, index: true
      t.string :email
      t.string :phone
      t.text :address, limit: 65535
      t.integer :contact_type, null: false, default: 0
      t.integer :status, null: false, default: 0
      t.boolean :is_private, default: false
      t.references :author, foreign_key: { to_table: :users }
      t.references :project
      t.references :user
      t.text :description, limit: 65535
      t.timestamps
    end
  end
end