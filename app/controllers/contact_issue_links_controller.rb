## `./app/controllers/contact_issue_links_controller.rb`

'''
### ContactIssueLinksController

  **Descrição:**  
  Controlador responsável por gerenciar vínculos entre contatos e issues (tickets). Permite associar ou desassociar contatos de uma issue.

  **Ações:**
  - `create`: Cria um novo vínculo entre um contato e uma issue
  - `destroy`: Remove um vínculo existente

  **Filtros:**
  - `require_login`: Exige que o usuário esteja logado
  - `find_issue`: Carrega a issue com base em `params[:issue_id]`
  - `find_contact_issue_link`: Localiza o vínculo específico a ser removido
  - `authorize`: Verifica se o usuário tem permissão para gerenciar contatos no projeto

---
'''

class ContactIssueLinksController < ApplicationController
  before_action :require_login
  before_action :find_issue
  before_action :find_contact_issue_link, only: [:destroy]
  before_action :authorize
  
  def create
    @link = @issue.contact_issue_links.build
    @link.safe_attributes = params[:contact_issue_link]
    
    if @link.save
      respond_to do |format|
        format.html {
          flash[:notice] = l(:notice_contact_linked_to_issue)
          redirect_back_or_default issue_path(@issue)
        }
        format.js
        format.api { render action: 'show', status: :created }
      end
    else
      respond_to do |format|
        format.html {
          flash[:error] = @link.errors.full_messages.join(', ')
          redirect_back_or_default issue_path(@issue)
        }
        format.js { render json: @link.errors, status: :unprocessable_entity }
        format.api { render_validation_errors(@link) }
      end
    end
  end
  
  def destroy
    @link.destroy
    
    respond_to do |format|
      format.html {
        flash[:notice] = l(:notice_contact_unlinked_from_issue)
        redirect_back_or_default issue_path(@issue)
      }
      format.js
      format.api { render_api_ok }
    end
  end
  
  private
  
  def find_issue
    @issue = Issue.find(params[:issue_id])
    @project = @issue.project
  rescue ActiveRecord::RecordNotFound
    render_404
  end
  
  def find_contact_issue_link
    @link = @issue.contact_issue_links.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end
  
  def authorize
    unless User.current.allowed_to?(:manage_contacts, @project)
      deny_access
      return false
    end
    true
  end
end