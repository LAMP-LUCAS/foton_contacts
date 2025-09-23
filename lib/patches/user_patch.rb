module Patches
  module UserPatch
    def self.included(base)
      base.class_eval do
        has_one :contact, dependent: :nullify

        after_create :create_contact_profile, if: :create_contact_profile?

        private

        def create_contact_profile?
          Setting.plugin_foton_contacts['create_user_contact'].to_i == 1
        end

        def create_contact_profile
          Contact.create(
            name: self.name,
            email: self.mail,
            contact_type: 'person',
            status: 'active',
            is_private: false,
            author: User.current || User.first,
            user: self
          )
        end
      end
    end
  end
end