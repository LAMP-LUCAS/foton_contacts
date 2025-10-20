class AddTrigramIndexesForFuzzySearch < ActiveRecord::Migration[7.1]
  def change
    add_index :foton_contacts, :name, using: :gin, opclass: { name: :gin_trgm_ops } unless index_exists?(:foton_contacts, :name, using: :gin)
    add_index :foton_contact_addresses, :address, using: :gin, opclass: { address: :gin_trgm_ops } unless index_exists?(:foton_contact_addresses, :address, using: :gin)
    add_index :foton_contact_emails, :email unless index_exists?(:foton_contact_emails, :email)
    add_index :foton_contact_phones, :phone unless index_exists?(:foton_contact_phones, :phone)
  end
end
