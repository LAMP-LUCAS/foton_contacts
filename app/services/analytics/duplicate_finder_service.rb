# frozen_string_literal: true

# frozen_string_literal: true

class Analytics::DuplicateFinderService
  SIMILARITY_THRESHOLD = 0.5 # Adjust this value (0.0 to 1.0) for name/address similarity

  def self.call
    new.call
  end

  def call
    duplicates = {}

    find_by_exact_email.each { |pair| (duplicates[pair.sort] ||= []) << "E-mail idêntico" }
    find_by_exact_phone.each { |pair| (duplicates[pair.sort] ||= []) << "Telefone idêntico" }
    find_by_similar_name.each { |pair| (duplicates[pair.sort] ||= []) << "Nome similar" }
    find_by_similar_address.each { |pair| (duplicates[pair.sort] ||= []) << "Endereço similar" }

    # Remove ignored pairs
    ignored_pairs = DataQualityIgnore.all.map { |i| [i.contact_a_id, i.contact_b_id] }
    duplicates.reject! { |pair, _| ignored_pairs.include?(pair) }

    format_results(duplicates)
  end

  private

  def find_by_exact_email
    contact_ids_by_email = FotonContactEmail.where.not(email: '').group(:email).having('COUNT(id) > 1').pluck(:email, 'array_agg(contact_id)')
    contact_ids_by_email.flat_map { |_, ids| ids.combination(2).to_a }
  end

  def find_by_exact_phone
    contact_ids_by_phone = FotonContactPhone.where.not(phone: '').group(:phone).having('COUNT(id) > 1').pluck(:phone, 'array_agg(contact_id)')
    contact_ids_by_phone.flat_map { |_, ids| ids.combination(2).to_a }
  end

  def find_by_similar_name
    FotonContact.joins("JOIN foton_contacts c2 ON foton_contacts.id < c2.id")
                .where("similarity(foton_contacts.name, c2.name) > ?", SIMILARITY_THRESHOLD)
                .pluck('foton_contacts.id', 'c2.id')
  end

  def find_by_similar_address
    FotonContactAddress.joins("JOIN foton_contact_addresses a2 ON foton_contact_addresses.id < a2.id")
                       .where("foton_contact_addresses.contact_id != a2.contact_id")
                       .where("similarity(foton_contact_addresses.address, a2.address) > ?", SIMILARITY_THRESHOLD)
                       .pluck('foton_contact_addresses.contact_id', 'a2.contact_id')
  end

  def format_results(duplicates)
    duplicates.map do |pair, reasons|
      [pair.first, pair.last, reasons.uniq.join(', ')]
    end
  end
end
