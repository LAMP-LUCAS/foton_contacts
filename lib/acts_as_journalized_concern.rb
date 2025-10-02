# lib/acts_as_journalized_concern.rb
module ActsAsJournalizedConcern
  extend ActiveSupport::Concern

  included do
    has_many :journals, as: :journalized, dependent: :destroy, class_name: 'Journal'

    # Define um método de classe para configurar o journaling
    def self.acts_as_journalized(options = {})
      cattr_accessor :journalized_attributes
      self.journalized_attributes = options[:watch].map(&:to_s) if options[:watch].present?

      after_save :create_journal_entry
    end

    # Adicionar este método de instância para satisfazer a expectativa da classe Journal do Redmine
    def journalized_attribute_names
      self.class.journalized_attributes || []
    end
  end

  # Callback method para criar uma entrada de journal após salvar
  def create_journal_entry
    return unless self.class.journalized_attributes.present? && self.persisted?

    # Coleta as mudanças apenas dos atributos monitorados
    changes_to_watch = self.saved_changes.slice(*self.class.journalized_attributes)
    return if changes_to_watch.empty?

    # Cria uma nova entrada de journal
    # Assumindo que User.current está disponível no contexto do Redmine
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