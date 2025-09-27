class DropContactRoles < ActiveRecord::Migration[6.1]
  def up
    if table_exists?(:contact_roles)
      drop_table :contact_roles
    end
  end

  def down
    # Se for necessário reverter, recriamos a tabela.
    # O ideal é copiar a estrutura de 002_create_contact_roles.rb
    create_table :contact_roles do |t|
      t.references :contact, foreign_key: true, null: false
      t.references :company, foreign_key: { to_table: :contacts }, null: false
      t.string :position
      t.date :start_date
      t.date :end_date
      t.timestamps
    end
  end
end
