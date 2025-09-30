## `./app/models/company_contact_option_collection.rb`

'''
### CompanyContactOptionCollection

  **Descrição:**  
  Classe de serviço responsável por fornecer uma coleção de opções de empresas (contatos do tipo empresa) para uso em selects/dropdowns. Filtra empresas ativas e opcionalmente por projeto.

  **Propósito:**
  - Centralizar a lógica de busca de empresas ativas
  - Formatar dados para uso em formulários e filtros
  - Permitir filtragem opcional por projeto

  **Método Principal:**
  - `options`: Retorna um array de arrays no formato `[nome_da_empresa, id_da_empresa]`

  **Funcionamento:**
  1. Busca todos os contatos do tipo empresa com status ativo
  2. Aplica filtro por projeto se especificado
  3. Mapeia os resultados para o formato esperado por helpers como `options_for_select`

  **Exemplo de Uso:**
  ```ruby
  # Todas as empresas ativas
  options = CompanyContactOptionCollection.new.options
  # => [["Empresa A", 1], ["Empresa B", 2], ...]

  # Empresas ativas de um projeto específico
  options = CompanyContactOptionCollection.new(project).options
  # => [["Empresa do Projeto", 3], ...]
  ```

  **Dependências:**
  - Assume que o modelo `Contact` possui os scopes `company` e `active`
  - Utiliza a estrutura de projetos do Redmine

---

'''

class CompanyContactOptionCollection
  def initialize(project = nil)
    @project = project
  end

  def options
    contacts = Contact.company.active
    contacts = contacts.where(project: @project) if @project
    contacts.map { |c| [c.name, c.id] }
  end
end