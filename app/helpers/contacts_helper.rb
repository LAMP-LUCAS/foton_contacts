module ContactsHelper
  def options_for_company_contact(options = {})
    company_scope = Contact.companies.order(:name)
    options_array = company_scope.map { |c| [c.name, c.id] }
    options_for_select(options_array, options[:selected])
  end

  def display_role_for_contact_in_issue(contact, issue)
    # Find the role from the direct link, if it exists.
    direct_role = issue.contact_issue_links.find { |link| link.contact_id == contact.id }&.role

    # Find all unique roles from the groups the contact is a member of.
    contact_group_ids = contact.contact_group_ids
    group_roles = if contact_group_ids.any?
                    issue.contact_issue_links.filter_map do |link|
                      link.role if link.contact_group_id.present? && contact_group_ids.include?(link.contact_group_id)
                    end.uniq
                  else
                    []
                  end

    # Consolidate for display
    if direct_role.present? && group_roles.any?
      safe_join([group_roles.join(', '), direct_role], ' / ')
    elsif direct_role.present?
      direct_role
    elsif group_roles.any?
      group_roles.join(', ')
    end
  end
end