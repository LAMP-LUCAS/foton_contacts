class InitFotonContactsSchema < ActiveRecord::Migration[7.1]
  def change
    # Enable pg_trgm for fuzzy search
    enable_extension 'pg_trgm' unless extension_enabled?('pg_trgm')

    create_table :foton_contacts do |t|
      t.string :name, null: false
      t.integer :contact_type, null: false, default: 0
      t.integer :status, null: false, default: 0
      t.boolean :is_private, default: false
      t.references :author, foreign_key: { to_table: :users }
      t.references :project
      t.references :user
      t.text :description, limit: 65535
      t.float :available_hours_per_day
      t.timestamps
    end
    add_index :foton_contacts, :name, using: :gin, opclass: { name: :gin_trgm_ops }, if_not_exists: true

    create_table :foton_contact_emails do |t|
      t.references :contact, null: false, foreign_key: { to_table: :foton_contacts }
      t.string :email, null: false
      t.boolean :is_primary, default: false
      t.timestamps
    end
    add_index :foton_contact_emails, :email, if_not_exists: true

    create_table :foton_contact_phones do |t|
      t.references :contact, null: false, foreign_key: { to_table: :foton_contacts }
      t.string :phone, null: false
      t.boolean :is_primary, default: false
      t.timestamps
    end
    add_index :foton_contact_phones, :phone, if_not_exists: true

    create_table :foton_contact_addresses do |t|
      t.references :contact, null: false, foreign_key: { to_table: :foton_contacts }
      t.text :address, limit: 65535
      t.boolean :is_primary, default: false
      t.timestamps
    end
    add_index :foton_contact_addresses, :address, using: :gin, opclass: { address: :gin_trgm_ops }, if_not_exists: true

    create_table :contact_groups do |t|
      t.string :name, null: false
      t.text :description
      t.integer :group_type, null: false, default: 0
      t.references :author, foreign_key: { to_table: :users }
      t.references :project
      t.timestamps
    end

    create_table :contact_group_memberships do |t|
      t.references :contact, null: false, foreign_key: { to_table: :foton_contacts }
      t.references :contact_group, null: false, foreign_key: true
      t.string :role
      t.text :notes
      t.timestamps
      t.index [:contact_id, :contact_group_id], unique: true, name: 'idx_contact_group_memberships_on_contact_and_group'
    end

    create_table :contact_issue_links do |t|
      t.references :issue, null: false, foreign_key: true
      t.references :contact, null: true, foreign_key: { to_table: :foton_contacts }
      t.references :contact_group, null: true, foreign_key: true
      t.string :role
      t.text :notes
      t.timestamps
      t.index [:issue_id, :contact_id], name: 'idx_contact_issue_links_on_issue_and_contact', unique: true, where: 'contact_id IS NOT NULL'
      t.index [:issue_id, :contact_group_id], name: 'idx_contact_issue_links_on_issue_and_group', unique: true, where: 'contact_group_id IS NOT NULL'
    end

    create_table :contact_employments do |t|
      t.references :contact, null: false, foreign_key: { to_table: :foton_contacts }
      t.references :company, null: false, foreign_key: { to_table: :foton_contacts }
      t.string :position
      t.date :start_date, default: -> { "CURRENT_DATE" }
      t.date :end_date
      t.timestamps
    end
    add_index :contact_employments, [:contact_id, :company_id], unique: true, where: "end_date IS NULL", if_not_exists: true

    create_table :data_quality_ignores do |t|
      t.integer :contact_a_id, null: false
      t.integer :contact_b_id, null: false
      t.timestamps
    end
    add_index :data_quality_ignores, [:contact_a_id, :contact_b_id], unique: true, name: 'idx_on_contact_a_id_and_contact_b_id', if_not_exists: true

    create_table :imported_contacts do |t|
      t.string :import_batch_id, null: false
      t.string :status, null: false, default: 'pending_review'
      t.integer :potential_duplicate_id
      t.text :raw_data
      t.string :name
      t.string :email
      t.string :phone
      t.text :description
      t.timestamps
    end
    add_index :imported_contacts, :import_batch_id, if_not_exists: true
    add_index :imported_contacts, :status, if_not_exists: true
    add_index :imported_contacts, :potential_duplicate_id, if_not_exists: true
  end
end