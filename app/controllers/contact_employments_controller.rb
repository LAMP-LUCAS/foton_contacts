class ContactEmploymentsController < ApplicationController
  before_action :require_login
  before_action :find_employment, only: [:destroy]

  def new
    @contact = Contact.find(params[:contact_id])
    @employment = @contact.employments_as_person.new
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def create
    @contact = Contact.find(params[:contact_employment][:contact_id])
    @employment = @contact.employments_as_person.new(employment_params)

    respond_to do |format|
      if @employment.save
        format.html { redirect_to contact_path(@contact, tab: 'career_history'), notice: l(:notice_successful_create) }
        format.turbo_stream
      else
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream { render :new, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @contact = @employment.person
    @employment.destroy
    respond_to do |format|
      format.html { redirect_to contact_path(@contact, tab: 'career_history'), notice: l(:notice_successful_delete) }
      format.turbo_stream
    end
  end

  private

  def find_employment
    @employment = ContactEmployment.find(params[:id])
  end

  def employment_params
    params.require(:contact_employment).permit(:company_id, :role, :start_date, :end_date)
  end
end