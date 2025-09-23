class CreateContactGroupMemberships < ActiveRecord::Migration[5.2]
  def change
    create_table :contact_group_memberships do |t|
      t.references :contact, null: false, foreign_key: true
      t.references :contact_group, null: false, foreign_key: true
      t.string :role
      t.text :notes
      t.timestamps

      t.index [:contact_id, :contact_group_id], unique: true, name: 'idx_contact_group_memberships_on_contact_and_group'
    end
  end
end