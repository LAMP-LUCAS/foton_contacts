## `./app/models/contact_issue_link.rb`

'''
### ContactIssueLink

  **Descrição:**  
  Modelo que representa o vínculo entre um Contato e uma Issue. Permite associar contatos a tickets/issues com informações contextuais.

  **Relacionamentos:**
  - `belongs_to :contact`
  - `belongs_to :issue`

  **Validações:**
  - `contact_id` e `issue_id` obrigatórios
  - Combinação `contact_id` + `issue_id` única

  **Atributos Seguros:**
  - `contact_id`, `issue_id`, `role`, `notes`

  **Métodos Principais:**
  - `visible?`: Verifica se o vínculo é visível para o usuário (baseado na visibilidade do contato e issue)
  - `to_s`: Representação em string formatada

---

'''

class ContactIssueLink < ActiveRecord::Base
  include Redmine::SafeAttributes
  
  belongs_to :contact
  belongs_to :issue
  
  validates :contact_id, presence: true
  validates :issue_id, presence: true
  validates :contact_id, uniqueness: { scope: :issue_id }
  
  safe_attributes 'contact_id',
                 'issue_id',
                 'role',
                 'notes'
  
  def to_s
    "#{contact} (#{role})"
  end
  
  def visible?(user)
    contact.visible?(user) && issue.visible?(user)
  end
end