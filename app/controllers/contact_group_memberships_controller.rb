class ContactGroupMembershipsController < ApplicationController
  helper FotonContactsLinkHelper
  before_action :find_membership, only: [:update]
  before_action :authorize_membership_update

  def update
    if @membership.update(membership_params)
      respond_to do |format|
        format.turbo_stream {
          render turbo_stream: turbo_stream.replace(@membership,
            partial: "contact_groups/member",
            locals: { membership: @membership })
        }
        format.html { redirect_to @membership.contact_group, notice: l(:notice_successful_update) }
      end
    else
      respond_to do |format|
        format.html { redirect_to @membership.contact_group, alert: 'Failed to update role.' }
        format.turbo_stream { head :unprocessable_entity }
      end
    end
  end

  private

  def find_membership
    @membership = ContactGroupMembership.find(params[:id])
  end

  def membership_params
    params.require(:contact_group_membership).permit(:role)
  end

  def authorize_membership_update
    # A group can be global (project is nil), so we need to handle that.
    # For now, we check global permission if project is absent.
    project = @membership.contact_group.project
    if project
      deny_access unless User.current.allowed_to?(:manage_contacts, project)
    else
      deny_access unless User.current.allowed_to_globally?(:manage_contacts, @membership.contact_group)
    end
  end
end
