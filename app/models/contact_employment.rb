'''
Modelo que representa um Vínculo Empregatício entre um Contato (pessoa) e uma Empresa.
Gerencia relações de trabalho/emprego com validações de tipo específicas.

**Descrição:**  
Modelo que representa um vínculo empregatício ou profissional entre um Contato do tipo **Pessoa** e um Contato do tipo **Empresa**. Gerencia relações de trabalho com validações que garantem a integridade dos tipos envolvidos.

**Relacionamentos:**
- `belongs_to :contact` (Pessoa - funcionário/colaborador)
- `belongs_to :company` (Empresa - empregadora)

**Validações:**
- `contact_id`: Presença obrigatória
- `company_id`: Presença obrigatória  
- `position`: Comprimento máximo de 255 caracteres (opcional)

**Validações Customizadas:**
- `contact_must_be_person`: Garante que o contact seja do tipo pessoa
- `company_must_be_company`: Garante que a company seja do tipo empresa

**Métodos Privados:**
- `contact_must_be_person`: Adiciona erro se o contact não for uma pessoa
- `company_must_be_company`: Adiciona erro se a company não for uma empresa

**Funcionalidade Principal:**  
Assegura que apenas contatos do tipo correto possam ser vinculados em relações empregatícias, mantendo a consistência dos dados e a lógica de negócio do sistema.
'''

class ContactEmployment < ApplicationRecord
  belongs_to :contact, class_name: 'Contact'
  belongs_to :company, class_name: 'Contact'

  validates :contact_id, presence: true
  validates :company_id, presence: true
  validates :position, length: { maximum: 255 }, allow_blank: true

  validate :contact_must_be_person
  validate :company_must_be_company
  # Escopos para facilitar consultas
  scope :active, -> { where(end_date: nil) }
  scope :inactive, -> { where.not(end_date: nil) }
  private

  def contact_must_be_person
    return if contact.blank? || contact.person?
    errors.add(:contact, :invalid, message: "deve ser do tipo pessoa")
  end

  def company_must_be_company
    return if company.blank? || company.company?
    errors.add(:company, :invalid, message: "deve ser do tipo empresa")
  end
end