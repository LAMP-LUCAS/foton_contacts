# frozen_string_literal: true
require 'csv'

class Contacts::Importers::GoogleCsvMapper
  def initialize(file)
    @file = file
  end

  def each_contact
    # Usar um bloco de resgate para o loop garante que uma linha malformada não quebre toda a importação.
    CSV.foreach(@file.path, headers: true, col_sep: ',', encoding: 'UTF-8') do |row|
      begin
        contact_data = to_contact_data(row)
        next if contact_data.nil? # Pula se a validação interna falhar
        yield contact_data if block_given?
      rescue => e
        Rails.logger.error "[GoogleCsvMapper] Failed to process row: #{row.to_h}. Error: #{e.message}"
      end
    end
  end

  private

  # --- MÉTODO PRINCIPAL DE MAPEAMENTO ---
  def to_contact_data(row)
    name_data = build_name_data(row)
    emails = build_emails_data(row)
    phones = build_phones_data(row)

    # Validação: Pula se não tiver um nome ou um meio de contato
    if name_data[:full_name].blank? || (emails.empty? && phones.empty?)
      Rails.logger.warn "[GoogleCsvMapper] Skipping row due to missing essential data: #{row.to_h}"
      return nil
    end

    # --- ESTRUTURA DE DADOS RICA ---
    {
      name:       name_data,
      emails:     emails,
      phones:     phones,
      employment: build_employment_data(row),
      groups:     build_groups_data(row),
      metadata:   build_metadata(row),
      notes:      row['Notes'].to_s.strip.presence
      # O CSV do Google não tem campos padronizados para endereços, relações ou websites.
    }.compact
  end

  # --- MÉTODOS DE CONSTRUÇÃO ROBUSTOS ---

  def build_name_data(row)
    full_name = [row['First Name'], row['Middle Name'], row['Last Name']].map(&:to_s).map(&:strip).reject(&:blank?).join(' ')
    full_name = row['Name'].to_s.strip if full_name.blank?
    {
      first_name: row['First Name'].to_s.strip,
      last_name:  row['Last Name'].to_s.strip,
      full_name:  full_name
    }.compact.reject { |_, v| v.blank? }
  end

  def build_emails_data(row)
    emails = []
    (1..5).each do |i|
      email_value = row["E-mail #{i} - Value"].to_s.strip
      email_type = row["E-mail #{i} - Type"].to_s.strip.downcase.presence || 'other'
      emails << { type: email_type, value: email_value } if email_value.present?
    end
    emails.uniq { |e| e[:value] }
  end

  def build_phones_data(row)
    phones = []
    (1..5).each do |i|
      phone_value = row["Phone #{i} - Value"].to_s.strip
      phone_type = row["Phone #{i} - Type"].to_s.strip.downcase.presence || 'other'
      if phone_value.present?
        # Trata múltiplos números no mesmo campo
        phone_value.split(':::').each do |single_phone|
          phones << { type: phone_type, value: single_phone.gsub(/[^\d+]/, '').strip }
        end
      end
    end
    phones.uniq { |p| p[:value] }
  end

  def build_employment_data(row)
    employments = []
    (1..3).each do |i|
      company = row["Organization #{i} - Name"].to_s.strip
      title = row["Organization #{i} - Title"].to_s.strip
      department = row["Organization #{i} - Department"].to_s.strip
      
      if company.present? || title.present?
        employments << { company: company, title: title, department: department }.compact.reject { |_, v| v.blank? }
      end
    end
    employments.present? ? employments : nil
  end

  def build_groups_data(row)
    groups = row['Group Membership'].to_s.split(':::').map(&:strip).reject(&:blank?)
    groups.uniq.presence
  end

  def build_metadata(row)
    {
      birthday: row['Birthday'].to_s.strip.presence
      # O CSV não tem outros metadados padronizados como UID, TZ, etc.
    }.compact.presence
  end
end