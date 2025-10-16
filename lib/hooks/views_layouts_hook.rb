module Hooks
  class ViewsLayoutsHook < Redmine::Hook::ViewListener
    def view_layouts_base_html_head(context = {})
      # Use unpkg CDN to load Hotwire libraries
      turbo_tag = '<script src="https://unpkg.com/@hotwired/turbo@7.3.0/dist/turbo.es2017-umd.js"></script>'
      stimulus_tag = '<script src="https://unpkg.com/@hotwired/stimulus@3.2.2/dist/stimulus.umd.js"></script>'

      # Load Bootstrap CSS from local assets
      bootstrap_css_tag = context[:controller].view_context.stylesheet_link_tag('bootstrap.min', plugin: 'foton_contacts')

      # Load the plugin's CSS
      css_tag = context[:controller].view_context.stylesheet_link_tag('contacts', plugin: 'foton_contacts')

      # Load Bootstrap JS from local assets
      bootstrap_js_tag = context[:controller].view_context.javascript_include_tag('bootstrap.bundle.min', plugin: 'foton_contacts', 'data-turbo-track': 'reload', defer: true)
      
      # Load Tom Select JS
      tom_select_js_tag = context[:controller].view_context.javascript_include_tag('tom-select.complete.min', plugin: 'foton_contacts', 'data-turbo-track': 'reload', defer: true)

      # Load the plugin's JS as a standard script (NOT a module)
      plugin_js_tag = context[:controller].view_context.javascript_include_tag('application', plugin: 'foton_contacts', 'data-turbo-track': 'reload') #,defer:true)

      [turbo_tag, stimulus_tag, bootstrap_css_tag, css_tag, bootstrap_js_tag, tom_select_js_tag, plugin_js_tag].join("\n").html_safe
    end

    def view_issues_show_details_bottom(context = {})
      context[:controller].send(:render_to_string, {
        partial: 'issues/foton_contacts_section',
        locals: context
      })
    end
  end
end
