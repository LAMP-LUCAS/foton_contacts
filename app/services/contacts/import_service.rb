class Contacts::ImportService
  def self.call(file:)
    new(file: file).call
  end

  def initialize(file:, **_options)
    @file = file
    @import_batch_id = SecureRandom.uuid
    @created_count = 0
    Rails.logger.info "[ImportService] Initialized for batch #{@import_batch_id}"
  end

  def call
    mapper.each_contact do |raw_contact_data|
      next if raw_contact_data.nil?

      contact_data = adapt_data_for_import(raw_contact_data, source_mapper: mapper.class)
      Rails.logger.info "[ImportService] Adapted data: #{contact_data.inspect}"
      
      attributes = contact_data.merge(
        import_batch_id: @import_batch_id,
        status: 'pending_review'
      )
      
      imported_contact = ImportedContact.create(attributes)
      if imported_contact.persisted?
        @created_count += 1
        Rails.logger.info "[ImportService] Created ImportedContact ##{imported_contact.id}"
      else
        Rails.logger.error "[ImportService] Failed: #{imported_contact.errors.full_messages.join(', ')}"
      end
    end
    
    Rails.logger.info "[ImportService] Finished. Created: #{@created_count}"
    { success: true, created_count: @created_count }
  end

  private

  # O "Porteiro" (Adapter) agora trata dados ricos de múltiplos mappers.
  def adapt_data_for_import(raw_data, source_mapper:)
    # Mappers que produzem dados ricos e precisam de adaptação.
    rich_data_mappers = [
      Contacts::Importers::VcardMapper,
      Contacts::Importers::GoogleCsvMapper
    ]

    # Se o mapper não produz dados ricos, retorna os dados como estão.
    return raw_data unless rich_data_mappers.include?(source_mapper)

    # --- LÓGICA DE ADAPTAÇÃO UNIFICADA ---
    description_notes = []

    # 1. Nome
    name_info = raw_data[:name] || {}
    main_name = name_info[:full_name].presence || [name_info[:prefix], name_info[:first_name], name_info[:middle_name], name_info[:last_name], name_info[:suffix]].compact.join(' ')
    description_notes << "- **Apelido:** #{name_info[:nickname]}" if name_info[:nickname].present?

    # 2. E-mails e Telefones
    emails = raw_data[:emails] || []
    phones = raw_data[:phones] || []
    primary_email = emails.first&.dig(:value)
    additional_emails = emails.map { |e| e[:value] }.uniq.drop(1)
    phones.each { |p| description_notes << "- **Telefone (#{p[:type]}):** #{p[:value]}" }
    primary_phone = phones.first&.dig(:value)
    additional_phones = phones.map { |p| p[:value] }.uniq.drop(1)
    emails.each { |e| description_notes << "- **Email (#{e[:type]}):** #{e[:value]}" }

    # 3. Emprego (suporta um ou múltiplos)
    employments = Array.wrap(raw_data[:employment])
    if employments.any?
      description_notes << "\n### Emprego"
      employments.each do |job|
        description_notes << "- **Empresa:** #{job[:company]}" if job[:company].present?
        description_notes << "  - **Departamento:** #{job[:department]}" if job[:department].present?
        description_notes << "  - **Cargo:** #{job[:title]}" if job[:title].present?
      end
    end

    # 4. Endereços
    addresses = raw_data[:addresses] || []
    if addresses.any?
      description_notes << "\n### Endereços"
      addresses.each_with_index do |addr, i|
        address_line = [addr[:street], addr[:city], addr[:region], addr[:postal_code], addr[:country]].compact.join(', ')
        description_notes << "- **Endereço #{i+1} (#{addr[:type]}):** #{address_line}" if address_line.present?
      end
    end

    # 5. Websites
    websites = raw_data[:websites] || []
    if websites.any?
      description_notes << "\n### Websites"
      websites.each { |w| description_notes << "- **(#{w[:type]}):** #{w[:value]}" }
    end

    # 6. Relações
    relations = raw_data[:relations] || []
    if relations.any?
      description_notes << "\n### Relações"
      relations.each { |r| description_notes << "- **(#{r[:type]}):** #{r[:value]}" }
    end

    # 7. Grupos/Tags
    groups = raw_data[:groups] || []
    if groups.any?
      description_notes << "\n### Grupos/Tags"
      description_notes << "- #{groups.join(', ')}"
    end

    # 8. Metadados
    metadata = raw_data[:metadata] || {}
    if metadata.any?
      description_notes << "\n### Metadados"
      metadata.each { |key, value| description_notes << "- **#{key.to_s.humanize}:** #{value}" }
    end

    # 9. Foto
    description_notes << "\n*Contém uma foto para ser processada.*" if raw_data[:photo].present?

    # 10. Junta tudo na descrição
    original_notes = raw_data[:notes]
    final_description = [original_notes, description_notes.join("\n").presence].compact.join("\n\n---\n\n")

    # 11. Monta o hash final para o ImportedContact
    {
      name: main_name,
      contact_type: 'person',
      description: final_description.presence,
      email: primary_email,
      phone: primary_phone,
      additional_emails: additional_emails,
      additional_phones: additional_phones
    }.compact
  end

  def mapper
    case @file.content_type
    when 'text/csv'
      Rails.logger.info "[ImportService] Using GoogleCsvMapper"
      Contacts::Importers::GoogleCsvMapper.new(@file)
    when 'text/x-vcard', 'text/vcard'
      Rails.logger.info "[ImportService] Using VcardMapper"
      Contacts::Importers::VcardMapper.new(@file)
    else
      raise "Unsupported file type: #{@file.content_type}"
    end
  end
end
