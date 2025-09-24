class CreateContactIssueLinks < ActiveRecord::Migration[5.2]
  def change
    create_table :contact_issue_links do |t|
      t.references :contact, null: false, foreign_key: true
      t.references :issue, null: false, foreign_key: true
      t.string :role
      t.text :notes
      t.timestamps

      t.index [:contact_id, :issue_id], unique: true
    end
  end
end