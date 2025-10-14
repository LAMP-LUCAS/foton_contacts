module ContactsHelper
  def options_for_company_contact(options = {})
    company_scope = Contact.companies.order(:name)
    options_array = company_scope.map { |c| [c.name, c.id] }
    options_for_select(options_array, options[:selected])
  end

  def display_role_for_contact_in_issue(contact, issue)
    # 1. Role from direct link (contact's role in the issue)
    direct_link = issue.contact_issue_links.find_by(contact_id: contact.id)
    return direct_link.role if direct_link&.role.present?

    # 2. Role from group membership (contact's role in the group)
    issue_group_ids = issue.contact_issue_links.where.not(contact_group_id: nil).pluck(:contact_group_id)
    if issue_group_ids.any?
      membership = contact.contact_group_memberships.find_by(contact_group_id: issue_group_ids)
      return membership.role if membership&.role.present?
    end

    '---'
  end

  def display_group_info_for_contact_in_issue(contact, issue)
    # Find group IDs linked to the issue
    issue_group_ids = issue.contact_issue_links.where.not(contact_group_id: nil).pluck(:contact_group_id)
    return '---' if issue_group_ids.empty?

    # Find a group the contact is a member of from the list of linked groups
    membership = contact.contact_group_memberships.find_by(contact_group_id: issue_group_ids)
    return '---' unless membership

    group = membership.contact_group
    
    # Find the issue link for that group to get the group's role in the issue
    group_link = issue.contact_issue_links.find_by(contact_group_id: group.id)

    role_text = group_link&.role.present? ? " / #{group_link.role}" : ""
    
    "#{group.name}#{role_text}"
  end

end