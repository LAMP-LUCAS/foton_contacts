require 'redmine'
require_relative 'lib/hooks/views_layouts_hook'
require_relative 'lib/acts_as_journalized_concern'


# require_dependency 'foton_contacts/hooks'

Redmine::Plugin.register :foton_contacts do
  name 'Foton Contacts'
  author 'Mundo AEC'
  author_url 'https://mundoaec.com/'
  description 'Plugin de gestão de contatos para o setor AEC'
  version '0.1.0'
  url 'https://mundoaec.com/'

  settings default: {
    'contact_types' => ['person', 'company'],
    'role_statuses' => ['active', 'inactive', 'discontinued'],
    'default_visibility' => 'private',
    'enable_groups' => true,
    'enable_issue_links' => true,
    'enable_custom_fields' => true,
    'enable_attachments' => true,
    'create_user_contact' => 1
  }, partial: 'settings/contact_settings'

  # Menu principal
  menu :top_menu,
       :contacts,
       { controller: 'contacts', action: 'index' },
       caption: :label_contacts,
       if: Proc.new { User.current.allowed_to?(:view_contacts, nil, global: true) }

  # Menu de configurações
  menu :admin_menu,
       :contact_settings,
       { controller: 'settings', action: 'plugin', id: 'foton_contacts' },
       caption: :label_contact_settings

  # Permissões
  project_module :contacts do |map|
    map.permission :view_contacts, { contacts: [:index, :show, :analytics], contact_groups: [:index, :show] }
    map.permission :manage_contacts, {
      contacts: [:new, :create, :edit, :update, :destroy, :import],
      contact_groups: [:new, :create, :edit, :update, :destroy, :add_member, :remove_member],
      contact_issue_links: [:create, :destroy]
    }
  end
end

# A partir do Redmine 6.0 (Rails 7.1), a melhor prática é registrar patches e assets no bloco `to_prepare`
Rails.configuration.to_prepare do
  # Registra os assets do plugin para pré-compilação
  Rails.application.config.assets.precompile += %w( application.js contacts.css select2.min.css contacts.js analytics.js )

  
  require_relative 'lib/patches/issue_patch'

  # Aplica o patch na classe User do Redmine
  unless User.included_modules.include?(Patches::UserPatch)
    User.send(:include, Patches::UserPatch)
  end

end
