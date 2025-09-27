# lib/patches/issue_patch.rb
module Patches
  module IssuePatch
    def self.prepended(base)
      base.has_many :contact_issue_links, dependent: :destroy
      base.has_many :contacts, through: :contact_issue_links
    end
  end
end


Issue.prepend Patches::IssuePatch