# foton_contacts/lib/patches/issue_patch.rb
module Patches
  module IssuePatch
    def self.prepended(base)
      base.class_eval do
        safe_attributes 'foton_contact_id',
                        'foton_contact_group_id'

        has_many :contact_issue_links, dependent: :destroy
        has_many :contacts, through: :contact_issue_links, class_name: 'FotonContact'
        has_many :contact_groups, through: :contact_issue_links
      end
    end
  end
end

Issue.prepend Patches::IssuePatch