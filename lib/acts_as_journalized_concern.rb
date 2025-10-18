# lib/acts_as_journalized_concern.rb
module ActsAsJournalizedConcern
  extend ActiveSupport::Concern

  included do
    has_many :journals, as: :journalized, dependent: :destroy, class_name: 'Journal'

    after_create :create_creation_journal_entry
    after_destroy :create_destruction_journal_entry
    after_save :create_update_journal_entry

    # Define um método de classe para configurar o journaling
    def self.acts_as_journalized(options = {})
      cattr_accessor :journalized_attributes
      self.journalized_attributes = options[:watch].map(&:to_s) if options[:watch].present?
    end

    # Adicionar este método de instância para satisfazer a expectativa da classe Journal do Redmine
    def journalized_attribute_names
      self.class.journalized_attributes || []
    end
  end

  # Callback para registrar atualizações nos atributos monitorados
  def create_update_journal_entry
    return unless self.class.journalized_attributes.present? && self.persisted?

    changes_to_watch = self.saved_changes.slice(*self.class.journalized_attributes)
    return if changes_to_watch.empty?

    journal = Journal.new(journalized: self, user: User.current)
    
    changes_to_watch.each do |attr, (old_value, new_value)|
      journal.details << JournalDetail.new(
        property: 'attr',
        prop_key: attr,
        old_value: old_value,
        value: new_value
      )
    end
    journal.save
  end

  # Callback para registrar a criação do objeto
  def create_creation_journal_entry
    journal = Journal.new(journalized: self, user: User.current, notes: "Created")
    journal.save
  end

  # Callback para registrar a destruição do objeto
  def create_destruction_journal_entry
    # Usamos Journal.create para garantir que seja salvo mesmo que o objeto esteja sendo destruído
    Journal.create(journalized: self, user: User.current, notes: "Destroyed")
  end

  # Métodos auxiliares existentes (mantidos)
  def last_journal_id
    new_record? ? nil : journals.maximum(:id)
  end

  def journals_after(journal_id)
    scope = journals.reorder("#{Journal.table_name}.id ASC")
    scope = scope.where("#{Journal.table_name}.id > ?", journal_id.to_i) if journal_id.present?
    scope
  end
end