class CreateImportedContacts < ActiveRecord::Migration[7.1]
  def change
    create_table :imported_contacts do |t|
      t.string :import_batch_id, null: false
      t.string :status, null: false, default: 'pending_review'
      t.integer :potential_duplicate_id, index: true
      t.text :raw_data
      t.string :name
      t.string :email
      t.string :phone
      t.text :description
      # Add any other fields you parse from the source file

      t.timestamps
    end

    add_index :imported_contacts, :import_batch_id
    add_index :imported_contacts, :status
  end
end
