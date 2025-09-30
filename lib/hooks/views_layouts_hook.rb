module Hooks
  class ViewsLayoutsHook < Redmine::Hook::ViewListener
    def view_layouts_base_html_head(context = {})
      tags = []
      
      # 1. Load Turbo from CDN
      tags << '<script src="https://cdn.jsdelivr.net/npm/@hotwired/turbo@8.0.4/dist/turbo.es2017-umd.js" defer></script>'

      # 2. Load the plugin's self-contained JS bundle (includes Stimulus and all controllers)
      tags << context[:controller].view_context.javascript_include_tag(
        'application',
        plugin: 'foton_contacts',
        defer: true
      )

      # 3. Include the plugin's CSS
      tags << context[:controller].view_context.stylesheet_link_tag(
        'contacts', 
        plugin: 'foton_contacts'
      )

      tags.join("\n").html_safe
    end
  end
end
