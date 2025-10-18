class InitFotonContactsSchema < ActiveRecord::Migration[6.1]
  def change
    create_table :foton_contacts do |t|
      t.string :name, null: false, index: true
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

    create_table :foton_contact_emails do |t|
      t.references :contact, null: false, foreign_key: { to_table: :foton_contacts }
      t.string :email, null: false
      t.boolean :is_primary, default: false
      t.timestamps
    end

    create_table :foton_contact_phones do |t|
      t.references :contact, null: false, foreign_key: { to_table: :foton_contacts }
      t.string :phone, null: false
      t.boolean :is_primary, default: false
      t.timestamps
    end

    create_table :foton_contact_addresses do |t|
      t.references :contact, null: false, foreign_key: { to_table: :foton_contacts }
      t.text :address, limit: 65535
      t.boolean :is_primary, default: false
      t.timestamps
    end

    create_table :contact_groups do |t|
      t.string :name, null: false
      t.text :description
      t.integer :group_type, null: false, default: 0 # 0: general, 1: private, 2: system
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

    add_index :contact_employments, [:contact_id, :company_id], unique: true, where: "end_date IS NULL"
  end
end