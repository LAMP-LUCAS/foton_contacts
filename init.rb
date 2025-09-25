require 'redmine'
#require_dependency 'foton_contacts/hooks'

# Registrar assets
Rails.application.config.assets.precompile += %w( jquery.js select2.min.js contacts.js )

Redmine::Plugin.register :foton_contacts do
  name 'Foton Contacts'
  author 'Mundo AEC'
  description 'Plugin de gestão de contatos para o setor AEC'
  version '0.1.0'
  url 'https://mundoaec.com/'
  author_url 'https://mundoaec.com/'

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

  # Permissões
  project_module :contacts do
    permission :view_contacts, { 
      contacts: [:index, :show],
      contact_groups: [:index, :show]
    }
    permission :manage_contacts, {
      contacts: [:new, :create, :edit, :update, :destroy],
      contact_roles: [:create, :update, :destroy],
      contact_groups: [:new, :create, :edit, :update, :destroy],
      contact_issue_links: [:create, :destroy]
    }
  end

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
end

# Patches e hooks são carregados automaticamente pelo Zeitwerk
# Este bloco garante que os patches sejam aplicados após o Redmine carregar suas classes
Rails.configuration.to_prepare do
  # Aplica o patch na classe User do Redmine
  unless User.included_modules.include?(Patches::UserPatch)
    User.send(:include, Patches::UserPatch)
  end
end