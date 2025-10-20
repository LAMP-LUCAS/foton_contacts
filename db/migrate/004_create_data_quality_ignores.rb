class CreateDataQualityIgnores < ActiveRecord::Migration[7.1]
  def change
    create_table :data_quality_ignores do |t| 
      t.integer :contact_a_id, null: false
      t.integer :contact_b_id, null: false
      t.timestamps
    end

    add_index :data_quality_ignores, [:contact_a_id, :contact_b_id], unique: true, name: 'idx_on_contact_a_id_and_contact_b_id'
  end
end
