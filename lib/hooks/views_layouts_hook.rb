module Hooks
  class ViewsLayoutsHook < Redmine::Hook::ViewListener
    def view_layouts_base_html_head(context = {})
      tags = []
      
      # 1. Load Turbo from CDN (with version bypass)
      tags << '<script src="https://cdn.jsdelivr.net/npm/@hotwired/turbo@8.0.4/dist/turbo.es2017-umd.js?v=1" defer></script>'

      # 2. Load Stimulus from CDN (with version bypass)
      tags << '<script src="https://cdn.jsdelivr.net/npm/@hotwired/stimulus@3.2.2/dist/stimulus.min.js?v=1" defer></script>'

      # 3. Load the plugin's JS bundle (classic script, depends on Stimulus)
      tags << context[:controller].view_context.javascript_include_tag(
        'foton_contacts_bundle',
        plugin: 'foton_contacts',
        defer: true
      )

      # 4. Include the plugin's CSS
      tags << context[:controller].view_context.stylesheet_link_tag(
        'contacts', 
        plugin: 'foton_contacts'
      )

      tags.join("\n").html_safe
    end
  end
end