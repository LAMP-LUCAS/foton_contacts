module RedmineApp
  class Application < Rails::Application
    # ...existing code...

    config.eager_load_paths << Rails.root.join('plugins', 'foton_contacts', 'lib')

    # ...existing code...
  end
end