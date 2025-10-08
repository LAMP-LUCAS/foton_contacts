class ContactIssueLinksController < ApplicationController
  helper FotonContactsLinkHelper
  before_action :find_issue, only: [:create, :destroy, :update]
  before_action :find_contact_issue_link, only: [:update, :destroy]
  before_action :authorize

  def create
    @contact_issue_link = @issue.contact_issue_links.build(contact_issue_link_params)

    if @contact_issue_link.save
      links_to_render = [@contact_issue_link]

      # Propagate role to group members if a group is linked with a role
      if @contact_issue_link.contact_group_id.present? && @contact_issue_link.role.present?
        group = @contact_issue_link.contact_group
        role = @contact_issue_link.role

        group.contacts.each do |member|
          member_link = @issue.contact_issue_links.find_or_initialize_by(contact: member)
          member_link.role = role
          member_link.save
        end
      end

      respond_to do |format|
        format.turbo_stream do
          target_id = if @contact_issue_link.contact_id
                        "search-result-contact-#{@contact_issue_link.contact_id}"
                      else
                        "search-result-group-#{@contact_issue_link.contact_group_id}"
                      end

          streams = [ turbo_stream.remove("no-contacts-message") ]

          links_to_render.each do |link|
            streams << turbo_stream.append(
              "issue_contact_links",
              partial: "issues/contact_issue_link",
              locals: { contact_issue_link: link }
            )
          end

          streams << turbo_stream.replace(
            target_id,
            partial: "issues/search_result_added",
            locals: { object: @contact_issue_link.linked_object }
          )

          streams << turbo_stream.update("issue_contacts_counter", html: @issue.contact_issue_links.reload.count)

          if @issue.contact_issue_links.count > 1
            streams << turbo_stream.replace("save_group_form_wrapper") do
              render_to_string partial: "issues/save_group_form", locals: { issue: @issue }
            end
          end

          render turbo_stream: streams
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

  def update
    if @contact_issue_link.update(contact_issue_link_params)
      respond_to do |format|
        format.turbo_stream {
          render turbo_stream: turbo_stream.replace(@contact_issue_link,
            partial: "issues/contact_issue_link",
            locals: { contact_issue_link: @contact_issue_link })
        }
        format.html { redirect_to @issue, notice: l(:notice_successful_update) }
      end
    else
      respond_to do |format|
        format.html { redirect_to @issue, alert: 'Failed to update contact link.' }
        format.turbo_stream { head :unprocessable_entity }
      end
    end
  end

  def destroy
    @linked_object = @contact_issue_link.linked_object

    if @contact_issue_link.destroy
      respond_to do |format|
        format.turbo_stream do
          streams = [
            turbo_stream.remove(@contact_issue_link),
            turbo_stream.update("issue_contacts_counter", html: @issue.contact_issue_links.count)
          ]

          if @issue.contact_issue_links.count <= 1
            streams << turbo_stream.replace("save_group_form_wrapper", "")
          end

          if @issue.contact_issue_links.count == 0
            streams << turbo_stream.append("issue_contact_links", "<p id=\"no-contacts-message\" class=\"no-data\">#{l(:label_foton_contacts_no_linked_contacts)}</p>")
          end

          render turbo_stream: streams
        end
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

  def find_contact_issue_link
    @contact_issue_link = @issue.contact_issue_links.find(params[:id])
  end

  def contact_issue_link_params
    params.require(:contact_issue_link).permit(:contact_id, :contact_group_id, :role)
  end

  def authorize
    deny_access unless User.current.allowed_to?(:manage_contacts, @issue.project)
  end
end
