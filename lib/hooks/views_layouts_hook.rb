module Hooks
  class ViewsLayoutsHook < Redmine::Hook::ViewListener
    def view_layouts_base_html_head(context = {})
      tags = []

      # Load the plugin's CSS
      tags << context[:controller].view_context.stylesheet_link_tag('contacts', plugin: 'foton_contacts')
      
      # Load the Hotwire javascript
      tags << context[:controller].view_context.javascript_include_tag('application', plugin: 'foton_contacts', 'data-turbo-track': 'reload', defer: true, type: 'module')

      tags.join("\n").html_safe
    end
  end
end
