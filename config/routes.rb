# Plugin routes
# See: http://guides.rubyonrails.org/routing.html

resources :contacts do
  member do
    get 'roles'
    get 'groups'
    get 'tasks'
    get 'history'
    get 'analytics'
  end
  collection do
    get 'search'
    get 'autocomplete'
    post 'import'
    get 'export'
  end
end

resources :contact_roles, except: [:index, :show, :new, :edit]
resources :contact_groups do
  member do
    post 'add_member'
    delete 'remove_member'
  end
end
resources :contact_issue_links, only: [:create, :destroy]

resources :projects do
  resources :contacts
end
# Configurações do plugin
get 'settings/plugin/foton_contacts', to: 'settings#plugin', as: 'contact_settings'