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
    get 'search_links'
    get 'autocomplete'
    post 'import'
    get 'export'
    post 'close_modal'
  end
end

resources :contact_roles, only: [] # Rota vazia para desativar
resources :contact_employments, only: [:new, :create, :edit, :update, :destroy]
resources :contact_group_memberships, only: [:update]
resources :contact_groups do
  member do
    get 'search_members'
    post 'add_member'
    delete 'remove_member'
  end
end

resources :issues do
  resources :contact_issue_links, only: [:create, :destroy, :update]
end

resources :projects do
  resources :contacts
end

# Analytics (BI)
scope '/analytics', as: 'analytics' do
  get '/', to: 'analytics#index', as: 'dashboard'

  # Rotas para o conteúdo das abas
  get 'overview_tab', to: 'analytics#overview_tab'
  get 'team_performance_tab', to: 'analytics#team_performance_tab'
  get 'workload_tab', to: 'analytics#workload_tab'
  get 'workload_results', to: 'analytics#workload_results'


  # Rotas para os widgets individuais (legado ou drill-down futuro)
  get 'team_performance', to: 'analytics#team_performance'
  get 'workload', to: 'analytics#workload'
  get 'irpa_widget', to: 'analytics#irpa_widget'
  get 'data_quality_widget', to: 'analytics#data_quality_widget'
  get 'partner_analysis_widget', to: 'analytics#partner_analysis_widget'
  get 'contact_details/:id', to: 'analytics#contact_details', as: :contact_details
  get 'dynamic_dashboard', to: 'analytics#dynamic_dashboard', as: :dynamic_dashboard
  get 'team_details/:id', to: 'analytics#team_details', as: :team_details
  get 'irpa_trend/:contact_id', to: 'analytics#irpa_trend', as: :irpa_trend
end

# Configurações do plugin
get 'settings/plugin/foton_contacts', to: 'settings#plugin', as: 'contact_settings'