class ConvertContactTypeAndStatusToEnum < ActiveRecord::Migration[7.0]
  def up
    # Backup dos valores atuais
    add_column :contacts, :contact_type_tmp, :integer
    add_column :contacts, :status_tmp, :integer

    # Converter contact_type de string para integer
    Contact.find_each do |contact|
      contact_type_value = case contact.read_attribute(:contact_type)
        when 'person' then 0
        when 'company' then 1
      end
      
      status_value = case contact.read_attribute(:status)
        when 'active' then 0
        when 'inactive' then 1
        when 'discontinued' then 2
      end
      
      contact.update_columns(
        contact_type_tmp: contact_type_value,
        status_tmp: status_value
      )
    end

    # Remover colunas antigas e renomear as novas
    remove_column :contacts, :contact_type
    remove_column :contacts, :status
    rename_column :contacts, :contact_type_tmp, :contact_type
    rename_column :contacts, :status_tmp, :status
    
    # Adicionar índices para melhor performance
    add_index :contacts, :contact_type
    add_index :contacts, :status
  end

  def down
    # Backup dos valores atuais
    add_column :contacts, :contact_type_tmp, :string
    add_column :contacts, :status_tmp, :string

    # Converter contact_type de integer para string
    Contact.find_each do |contact|
      contact_type_value = case contact.read_attribute(:contact_type)
        when 0 then 'person'
        when 1 then 'company'
      end
      
      status_value = case contact.read_attribute(:status)
        when 0 then 'active'
        when 1 then 'inactive'
        when 2 then 'discontinued'
      end
      
      contact.update_columns(
        contact_type_tmp: contact_type_value,
        status_tmp: status_value
      )
    end

    # Remover colunas antigas e renomear as novas
    remove_column :contacts, :contact_type
    remove_column :contacts, :status
    rename_column :contacts, :contact_type_tmp, :contact_type
    rename_column :contacts, :status_tmp, :status
    
    # Restaurar índices
    add_index :contacts, :contact_type
    add_index :contacts, :status
  end
end