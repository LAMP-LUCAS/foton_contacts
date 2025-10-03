# Plugin routes
# See: http://guides.rubyonrails.org/routing.html

resources :contacts do
  member do
    get 'career_history'
    get 'employees_list'
    get 'groups'
    get 'tasks'
    get 'history'
    get 'analytics'
    get 'show_edit'
  end
  collection do
    get :new_employment_field
    get 'search'
    get 'autocomplete'
    post 'import'
    get 'export'
    post 'close_modal'
  end
end

resources :contact_roles, only: [] # Rota vazia para desativar
resources :contact_employments, only: [:new, :create, :edit, :update, :destroy]
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