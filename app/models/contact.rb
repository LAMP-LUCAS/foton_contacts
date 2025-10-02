## `./app/models/contact.rb`
'''
### Contact

  **Descrição:**  
  Modelo principal que representa um Contato no sistema. Pode ser uma Pessoa ou uma Empresa, com atributos, relacionamentos e comportamentos específicos.

  **Principais Funcionalidades:**
  - Atributos seguros (safe_attributes) para massa assignment
  - Suporte a campos personalizados (acts_as_customizable)
  - Suporte a anexos (acts_as_attachable)
  - Sistema de busca (acts_as_searchable)
  - Registro de eventos (acts_as_event)

  **Relacionamentos:**
  - `belongs_to :author` (User que criou o contato)
  - `belongs_to :project` (opcional)
  - `belongs_to :user` (opcional - vinculação com usuário do sistema)
  - `has_many :contact_group_memberships` (vinculação com grupos)
  - `has_many :contact_groups` (grupos aos quais pertence)
  - `has_many :contact_issue_links` (vinculação com issues)
  - `has_many :issues` (issues associadas)
  - `has_many :employments_as_person` (vínculos como funcionário)
  - `has_many :employments_as_company` (vínculos como empregador)
  - `has_many :companies` (empresas onde trabalha)
  - `has_many :employees` (funcionários da empresa)

  **Validações:**
  - Nome obrigatório
  - Tipo de contato obrigatório (person/company)
  - Status obrigatório (active/inactive/discontinued)
  - Formato de email válido (quando preenchido)

  **Scopes:**
  - `persons`: Filtra apenas contatos do tipo pessoa
  - `companies`: Filtra apenas contatos do tipo empresa
  - `active`: Filtra contatos ativos
  - `visible`: Filtra contatos visíveis para o usuário

  **Métodos Principais:**
  - `company?`, `person?`: Verificam o tipo do contato
  - `active?`: Verifica se está ativo
  - `visible?`: Verifica visibilidade para um usuário
  - `to_s`: Representação em string (nome)
  - `css_classes`: Classes CSS para estilização
  - `contacts_to_csv`: Geração de CSV para exportação de contatos
  - `has_active_employments?`: Verifica se tem vínculos ativos
  - `active_employees`: Acessa pessoas ativas (quando é empresa)

---

'''
require 'csv'

class Contact < ActiveRecord::Base
  include Redmine::SafeAttributes
  include Redmine::Acts::Customizable
  include Redmine::Acts::Attachable
  include Redmine::Acts::Searchable
  include Redmine::Acts::Event
  # include Redmine::I18n
  acts_as_customizable
  acts_as_attachable
  include ActsAsJournalizedConcern # Add this line
  acts_as_journalized watch: %w(name email phone address contact_type status is_private project_id description) # This line now calls our custom method
  acts_as_searchable columns: %w(name email address description),
                     preload: [:author],
                     date_column: :created_at
  acts_as_event title: Proc.new { |o| "#{l(:label_contact)}: #{o.name}" },
                description: :description,
                datetime: :created_at,
                type: 'contact',
                url: Proc.new { |o| { controller: 'contacts', action: 'show', id: o.id } }
  
  belongs_to :author, class_name: 'User'
  belongs_to :project, optional: true
  belongs_to :user, optional: true
  
  has_many :contact_group_memberships, class_name: 'ContactGroupMembership', dependent: :destroy
  has_many :contact_groups, through: :contact_group_memberships, source: :contact_group
  
  has_many :contact_issue_links, class_name: 'ContactIssueLink', dependent: :destroy
  has_many :issues, through: :contact_issue_links
  
  # Associações para vínculos com empresas
  has_many :employments_as_person,
          class_name: 'ContactEmployment',
          foreign_key: :contact_id,
          dependent: :destroy

  has_many :employments_as_company,
          class_name: 'ContactEmployment',
          foreign_key: :company_id,
          dependent: :destroy

  has_many :companies, through: :employments_as_person, source: :company
  has_many :employees, through: :employments_as_company, source: :contact

  # Permitir atributos aninhados no formulário
  accepts_nested_attributes_for :employments_as_person, allow_destroy: true, reject_if: :all_blank

  validates :name, presence: true
  enum :contact_type, [:person, :company]
  enum :status, [:active, :inactive, :discontinued]
  
  validates :contact_type, presence: true
  validates :status, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP, allow_blank: true }
  
  scope :persons, -> { where(contact_type: contact_types[:person]) }
  scope :companies, -> { where(contact_type: contact_types[:company]) }
  scope :active, -> { where(status: statuses[:active]) }
  scope :visible, ->(user) do
    if user&.admin?
      all
    else
      where(is_private: false).or(where(author_id: user&.id))
    end
  end
  
  safe_attributes 'name',
                 'email',
                 'phone',
                 'address',
                 'contact_type',
                 'status',
                 'is_private',
                 'project_id',
                 'description',
                 'employments_as_person_attributes'

  def allowed_target_projects
    Project.allowed_to(User.current, :manage_contacts)
  end
  
  def company?
    contact_type == 'company'
  end
  
  def person?
    contact_type == 'person'
  end
  
  def active?
    status == 'active'
  end
  
  def attachments_visible?(user=User.current)
    visible?(user)
  end
  
  def attachments_editable?(user=User.current)
    visible?(user)
  end
  
  def notified_users
    []
  end
  
  def notified_watchers
    [] # Contacts do not have watchers in the same way as Issues, so return an empty array.
  end

  def notified_mentions
    [] # Contacts do not have a mention system, so return an empty array.
  end
  
  def recipients
    notified_users.map(&:mail)
  end
  
  def visible?(user)
    return true if user&.admin?
    !is_private || author_id == user&.id
  end
  
  def to_s
    name
  end
  
  def css_classes
    [contact_type, status].join(' ')
  end

  def self.contacts_to_csv(contacts)
    CSV.generate(col_sep: ',') do |csv|
      csv << ["ID", "Name", "Email", "Phone", "Address", "Type", "Status", "Project", "Description"] # Header row
      contacts.each do |contact|
        csv << [
          contact.id,
          contact.name,
          contact.email,
          contact.phone,
          contact.address,
          contact.contact_type,
          contact.status,
          contact.project&.name, # Use & for safe navigation in case project is nil
          contact.description
        ]
      end
    end
  end

  # Método para verificar se tem vínculos ativos
  def has_active_employments?
    employments_as_person.active.any?
  end

  # Método para acessar pessoas ativas (quando é empresa)
  def active_employees
    employees.joins(:employments_as_person).merge(ContactEmployment.active)
  end
end
