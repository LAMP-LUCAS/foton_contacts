
## `./app/models/contact_group_membership.rb`

'''
### ContactGroupMembership

  **Descrição:**  
  Modelo de junção que representa a associação entre um Contato e um Grupo. Armazena a relação muitos-para-muitos com metadados adicionais.

  **Relacionamentos:**
  - `belongs_to :contact`
  - `belongs_to :contact_group`

  **Validações:**
  - `contact_id` e `contact_group_id` obrigatórios
  - Combinação `contact_id` + `contact_group_id` única

  **Atributos Seguros:**
  - `contact_id`, `contact_group_id`, `role`, `notes`

  **Métodos:**
  - `to_s`: Representação em string formatada

---

'''

class ContactGroupMembership < ActiveRecord::Base
  include Redmine::SafeAttributes
  
  belongs_to :contact
  belongs_to :contact_group
  
  validates :contact_id, presence: true
  validates :contact_group_id, presence: true
  validates :contact_id, uniqueness: { scope: :contact_group_id }
  
  safe_attributes 'contact_id',
                 'contact_group_id',
                 'role',
                 'notes'
  
  def to_s
    "#{contact} (#{role})"
  end
end