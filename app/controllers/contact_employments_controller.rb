class ContactEmploymentsController < ApplicationController
  helper :contacts
  before_action :require_login
  before_action :find_employment, only: [:edit, :update, :destroy]
  before_action :find_contact, only: [:create]

  def edit
    @contact = @employment.contact
    respond_to do |format|
      format.html # Mantém o fallback para navegação normal
      format.turbo_stream do
        render turbo_stream: turbo_stream.update("modal",
          partial: "contact_employments/form",
          locals: { employment: @employment, contact: @contact })
      end
    end
  end

  def create
    @employment = ContactEmployment.new(contact_employment_params)

    if @employment.save
      # Sucesso: Responde com Turbo Stream para atualizar a lista
      respond_to do |format|
        format.turbo_stream do
          # Re-renderiza a aba inteira com a lista atualizada e um formulário novo
          @contact_employments = @contact.employments_as_person.includes(:company)
          @employment = @contact.employments_as_person.new # Prepara um novo formulário
          render turbo_stream: turbo_stream.replace("contact_career_history",
                                                    partial: "contacts/show_tabs/career_history",
                                                    locals: { contact: @contact, contact_employments: @contact_employments })
        end
        format.html { redirect_to contact_path(@contact, tab: 'career_history'), notice: l(:notice_successful_create) }
      end
    else
      # Falha: Responde com Turbo Stream para mostrar os erros no formulário
      respond_to do |format|
        format.turbo_stream do
          # Substitui o frame do formulário por um que contém os erros de validação
          render turbo_stream: turbo_stream.replace("new_employment_form",
                                                    partial: "contact_employments/form",
                                                    locals: { employment: @employment, contact: @contact }),
                                                    status: :unprocessable_entity
        end
        format.html do
          @contact_employments = @contact.employments_as_person.includes(:company)
          render "contacts/show_tabs/_career_history", layout: false, status: :unprocessable_entity
        end
      end
    end
  end

  def update
    @contact = @employment.contact
    respond_to do |format|
      if @employment.update(contact_employment_params)
        # Resposta para requisições Turbo Stream
        format.turbo_stream

        # Resposta para requisições HTML normais (fallback)
        format.html { redirect_to contact_path(@contact, tab: 'career_history'), notice: l(:notice_successful_update) }
      else
        # Se houver erro de validação
        format.turbo_stream do
          render turbo_stream: turbo_stream.update("modal",
            partial: "contact_employments/form",
            locals: { employment: @employment, contact: @contact }),
            status: :unprocessable_entity
        end
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @contact = @employment.contact
    @employment.destroy
    redirect_to contact_path(@contact, tab: 'career_history'), status: :see_other, notice: l(:notice_successful_delete)
  end

  private

  def find_contact
    # Handles finding contact from both new action link and form submission
    contact_id = params[:contact_id] || params.dig(:contact_employment, :contact_id)
    @contact = Contact.find(contact_id)
  end

  def find_employment
    @employment = ContactEmployment.find(params[:id])
  end


  def contact_employment_params
    params.require(:contact_employment).permit(:contact_id, :company_id, :position, :start_date, :end_date)
  end
end