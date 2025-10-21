# frozen_string_literal: true

class Contacts::Importers::VcardMapper
  def initialize(file)
    @file = file
    Rails.logger.info "[VcardMapper] Initialized for file: #{@file.original_filename}"
  end

  def each_contact
    file_content = @file.read.force_encoding('UTF-8')
    vcard_strings = file_content.split("BEGIN:VCARD").reject(&:blank?).map { |s| "BEGIN:VCARD" + s }
    
    Rails.logger.info "[VcardMapper] Processing #{vcard_strings.size} vCards"

    vcard_strings.each_with_index do |vcard_string, index|
      # Bloco begin/rescue DENTRO do loop para resiliência máxima.
      # Um vCard quebrado não irá parar toda a importação.
      begin
        vcard = VCardigan.parse(vcard_string)
        contact_data = map(vcard)

        # Validação final: Pula contatos sem nome ou sem email/telefone
        if contact_data.blank? || contact_data.dig(:name, :full_name).blank? || (contact_data[:emails].blank? && contact_data[:phones].blank?)
          Rails.logger.warn "[VcardMapper] SKIPPING vCard #{index + 1} due to missing essential data (name, email, or phone)."
          next
        end

        Rails.logger.debug "[VcardMapper] Processed vCard #{index + 1}: #{contact_data.dig(:name, :full_name)}"
        yield contact_data if block_given?

      rescue => e
        Rails.logger.error "[VcardMapper] FAILED to parse vCard #{index + 1}. Error: #{e.message} | Backtrace: #{e.backtrace.first(5).join(" | ")}"
      end
    end
  end

  private

  def map(vcard)
    return nil unless vcard
    {
      name:       build_name_data(vcard),
      emails:     build_emails_data(vcard),
      phones:     build_phones_data(vcard),
      addresses:  build_addresses_data(vcard),
      employment: build_employment_data(vcard),
      websites:   build_websites_data(vcard),
      relations:  build_relations_data(vcard),
      groups:     build_groups_data(vcard),
      metadata:   build_metadata(vcard),
      notes:      build_notes_data(vcard),
      photo:      extract_photo(vcard)
    }.compact
  end

  # --- MÉTODOS DE CONSTRUÇÃO "À PROVA DE BALAS" ---

  def build_name_data(vcard)
    name_data = { full_name: vcard.fn&.first&.value.to_s.strip }
    name_value = vcard.n&.first&.value

    if name_value.respond_to?(:given_name)
      name_data.merge!({
        first_name:  name_value.given_name.to_s.strip,
        last_name:   name_value.family_name.to_s.strip,
        middle_name: name_value.additional_names.to_s.strip,
        prefix:      name_value.honorific_prefixes.to_s.strip,
        suffix:      name_value.honorific_suffixes.to_s.strip
      }.compact)
    elsif name_value.is_a?(String)
      parts = name_value.split(' ')
      name_data[:first_name] ||= parts.first
      name_data[:last_name] ||= parts.last if parts.size > 1
    end

    name_data[:nickname] = vcard.nickname&.first&.value.to_s.strip
    name_data[:full_name] = [name_data[:prefix], name_data[:first_name], name_data[:middle_name], name_data[:last_name], name_data[:suffix]].compact.join(' ') if name_data[:full_name].blank?
    
    name_data.compact.reject { |_, v| v.blank? }
  end

  # Abordagem defensiva para extrair tipo e valor
  def extract_typed_value(field, default_type = 'other')
    type = field.respond_to?(:type) ? Array.wrap(field.type).first.to_s.downcase : default_type
    value = field.respond_to?(:value) ? field.value.to_s.strip : field.to_s.strip
    { type: type, value: value }
  end

  def build_emails_data(vcard)
    Array.wrap(vcard.email).map { |field| extract_typed_value(field) }.reject { |email| email[:value].blank? }
  end

  def build_phones_data(vcard)
    Array.wrap(vcard.tel).map do |field|
      data = extract_typed_value(field)
      data[:value] = data[:value].gsub(/["\s-]+/, '') # Limpeza específica para telefone
      data
    end.reject { |phone| phone[:value].blank? }
  end

  def build_websites_data(vcard)
    Array.wrap(vcard.url).map { |field| extract_typed_value(field, 'website') }.reject { |site| site[:value].blank? }
  end

  def build_relations_data(vcard)
    Array.wrap(vcard.related).map { |field| extract_typed_value(field, 'related') }.reject { |rel| rel[:value].blank? }
  end

  def build_addresses_data(vcard)
    Array.wrap(vcard.adr).map do |field|
      addr_value = field.respond_to?(:value) ? field.value : nil
      next unless addr_value.respond_to?(:street_address)
      {
        type:        field.respond_to?(:type) ? Array.wrap(field.type).first.to_s.downcase : 'other',
        street:      addr_value.street_address.to_s.strip,
        city:        addr_value.locality.to_s.strip,
        region:      addr_value.region.to_s.strip,
        postal_code: addr_value.postal_code.to_s.strip,
        country:     addr_value.country_name.to_s.strip
      }.compact
    end.compact.reject { |addr| addr.slice(:street, :city).values.all?(&:blank?) }
  end

  def build_employment_data(vcard)
    org_field = vcard.org&.first&.value
    return nil unless org_field || vcard.title
    company, department = org_field.is_a?(Array) ? org_field.map(&:strip) : [org_field.to_s.strip, nil]
    {
      company:    company,
      department: department,
      title:      vcard.title&.first&.value.to_s.strip
    }.compact.reject { |_, v| v.blank? }
  end

  def build_groups_data(vcard)
    Array.wrap(vcard.categories).flat_map { |cat| cat.value.to_s.split(',') }.map(&:strip).uniq.reject(&:blank?)
  end

  def build_metadata(vcard)
    {
      birthday:     vcard.bday&.first&.value,
      last_updated: vcard.rev&.first&.value,
      uid:          vcard.uid&.first&.value,
      language:     vcard.lang&.first&.value,
      timezone:     vcard.tz&.first&.value
    }.compact.reject { |_, v| v.blank? }
  end

  def build_notes_data(vcard)
    Array.wrap(vcard.note).map(&:value).join("\n\n").strip.presence
  end

  def extract_photo(vcard)
    photo_field = vcard.photo&.first
    return nil unless photo_field
    {
      type: photo_field.type,
      data: photo_field.value
    }.compact
  end
end
