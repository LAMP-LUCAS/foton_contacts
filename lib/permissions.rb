module FotonContacts
  class Permissions
    def self.register
      Redmine::AccessControl.map do |map|
        map.project_module :contacts do
          # Permissões básicas
          map.permission :view_contacts,
                        {
                          contacts: [:index, :show, :roles, :groups, :tasks, :history, :analytics],
                          contact_groups: [:index, :show]
                        },
                        read: true
          
          map.permission :manage_contacts,
                        {
                          contacts: [:new, :create, :edit, :update, :destroy, :import],
                          contact_roles: [:create, :update, :destroy],
                          contact_groups: [:new, :create, :edit, :update, :destroy, :add_member, :remove_member],
                          contact_issue_links: [:create, :destroy]
                        },
                        require: :loggedin
          
          # Permissões avançadas
          map.permission :manage_contact_settings,
                        {
                          settings: [:plugin]
                        },
                        require: :admin
                        
          map.permission :import_contacts,
                        {
                          contacts: [:import]
                        },
                        require: :loggedin
                        
          map.permission :export_contacts,
                        {
                          contacts: [:export]
                        },
                        require: :loggedin
        end
      end
    end
  end
end