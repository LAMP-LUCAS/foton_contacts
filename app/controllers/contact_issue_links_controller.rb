class ContactIssueLinksController < ApplicationController
  before_action :find_issue, only: [:create, :destroy]
  before_action :authorize

  def create
    @contact_issue_link = @issue.contact_issue_links.build(contact_issue_link_params)

    if @contact_issue_link.save
      respond_to do |format|
        format.turbo_stream do
          target_id = if @contact_issue_link.contact_id
                        "search-result-contact-#{@contact_issue_link.contact_id}"
                      else
                        "search-result-group-#{@contact_issue_link.contact_group_id}"
                      end

          render turbo_stream: [
            turbo_stream.remove("no-contacts-message"),
            turbo_stream.append(
              "issue_contact_links",
              partial: "issues/contact_issue_link",
              locals: { contact_issue_link: @contact_issue_link }
            ),
            turbo_stream.replace(
              target_id,
              partial: "issues/search_result_added",
              locals: { object: @contact_issue_link.linked_object }
            )
          ]
        end
        format.html { redirect_to @issue }
      end
    else
      # Handle errors, maybe render a turbo_stream to show errors
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "issue_contact_links_form",
            partial: "issues/contact_issue_links_form",
            locals: { issue: @issue, contact_issue_link: @contact_issue_link }
          )
        end
        format.html { redirect_to @issue, alert: @contact_issue_link.errors.full_messages.to_sentence }
      end
    end
  end

  def destroy
    @contact_issue_link = @issue.contact_issue_links.find(params[:id])
    @linked_object = @contact_issue_link.linked_object

    if @contact_issue_link.destroy
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @issue }
      end
    else
      respond_to do |format|
        format.turbo_stream do
          # Optionally render an error message via turbo_stream
          head :unprocessable_entity
        end
        format.html { redirect_to @issue, alert: @contact_issue_link.errors.full_messages.to_sentence }
      end
    end
  end

  private

  def find_issue
    @issue = Issue.find(params[:issue_id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def contact_issue_link_params
    params.require(:contact_issue_link).permit(:contact_id, :contact_group_id)
  end

  def authorize
    deny_access unless User.current.allowed_to?(:manage_contacts, @issue.project)
  end
end
