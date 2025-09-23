require 'redmine'

Redmine::Plugin.register :foton_contacts do
  name 'Foton Contacts'
  author 'Mundo AEC'
  description 'Plugin de gestão de contatos para o setor AEC'
  version '0.1.0'
  url 'https://mundoaec.com/'
  author_url 'https://mundoaec.com/'

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

# Adicionar lib ao $LOAD_PATH
lib_path = File.join(File.dirname(__FILE__), 'lib')
$LOAD_PATH.unshift(lib_path) unless $LOAD_PATH.include?(lib_path)

# Hooks e patches
require_dependency 'hooks/views_layouts_hook'
require_dependency 'patches/user_patch'