'''
Modelo que representa o Cargo/Função de um Contato (pessoa) em uma Empresa.
Gerencia a relação profissional entre pessoas e empresas.

Classe: ContactRole
  Descrição:
    Modelo que representa o cargo ou função que uma Pessoa (contato) exerce em uma Empresa (outro contato). Gerencia relações profissionais com status, datas e informações adicionais.

  Relacionamentos:

    belongs_to :contact (pessoa)
    belongs_to :company (empresa, também um Contact)

  Validações:

    Contact_id, company_id e position obrigatórios
    Status deve estar entre 0-2 (active/inactive/discontinued)
    Combinação contact_id + company_id + position única
    Validações customizadas para garantir tipos corretos

  Validações Customizadas:

    ensure_company_type: Company deve ser do tipo empresa
    ensure_person_type: Contact deve ser do tipo pessoa

  Scopes:
    active, inactive, discontinued: Filtros por status

  Métodos Principais:
      active?, inactive?, discontinued?: Verificadores de status
      status_name: Nome legível do status
'''

class ContactRole < ActiveRecord::Base
  include Redmine::SafeAttributes
  
  belongs_to :contact # pessoa
  belongs_to :company, class_name: 'Contact'
  
  validates :contact_id, presence: true
  validates :company_id, presence: true
  validates :position, presence: true
  validates :status, presence: true, inclusion: { in: 0..2 }
  validates :contact_id, uniqueness: { scope: [:company_id, :position] }
  validate :ensure_company_type
  validate :ensure_person_type
  
  scope :active, -> { where(status: 0) }
  scope :inactive, -> { where(status: 1) }
  scope :discontinued, -> { where(status: 2) }
  
  safe_attributes 'contact_id',
                 'company_id',
                 'position',
                 'status',
                 'start_date',
                 'end_date',
                 'notes'
  
  def active?
    status.zero?
  end
  
  def inactive?
    status == 1
  end
  
  def discontinued?
    status == 2
  end
  
  def status_name
    case status
    when 0 then 'active'
    when 1 then 'inactive'
    when 2 then 'discontinued'
    end
  end
  
  private
  
  def ensure_company_type
    if company && !company.company?
      errors.add(:company, :must_be_company)
    end
  end
  
  def ensure_person_type
    if contact && !contact.person?
      errors.add(:contact, :must_be_person)
    end
  end
end