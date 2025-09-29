class InitFotonContactsSchema < ActiveRecord::Migration[6.1]
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

    create_table :contact_groups do |t|
      t.string :name, null: false
      t.text :description
      t.integer :group_type, null: false, default: 0 # 0: general, 1: private, 2: system
      t.references :author, foreign_key: { to_table: :users }
      t.references :project
      t.timestamps
    end

    create_table :contact_group_memberships do |t|
      t.references :contact, null: false, foreign_key: true
      t.references :contact_group, null: false, foreign_key: true
      t.string :role
      t.text :notes
      t.timestamps

      t.index [:contact_id, :contact_group_id], unique: true, name: 'idx_contact_group_memberships_on_contact_and_group'
    end

    create_table :contact_issue_links do |t|
      t.references :contact, null: false, foreign_key: true
      t.references :issue, null: false, foreign_key: true
      t.string :role
      t.text :notes
      t.timestamps

      t.index [:contact_id, :issue_id], unique: true
    end

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
