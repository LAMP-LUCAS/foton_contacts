module Analytics
  class DataQualityQuery
    def self.calculate
      new.calculate
    end

    def calculate
      total_contacts = FotonContact.person.count.to_f
      return {} if total_contacts.zero?

      outdated_count = FotonContact.person.where('updated_at < ?', 1.year.ago).count
      
      # A simple metric for unstandardized roles: count roles used only once.
      role_counts = ContactIssueLink.where.not(role: [nil, '']).group(:role).count
      non_standard_count = role_counts.count { |_, count| count == 1 }

      {
        orphan_contacts: FotonContact.person.left_outer_joins(:contact_issue_links, :employments_as_person).where(contact_issue_links: { id: nil }, contact_employments: { id: nil }).distinct.count,
        outdated_contacts_count: outdated_count,
        outdated_contacts_percentage: (outdated_count / total_contacts * 100).round,
        unstandardized_roles_count: non_standard_count
      }
    end
  end
end