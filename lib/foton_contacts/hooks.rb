# lib/foton_contacts/hooks.rb
module FotonContacts
  class Hooks < Redmine::Hook::ViewListener
    def view_layouts_base_html_head(context)
      stylesheet_link_tag('contacts', plugin: 'foton_contacts') +
      javascript_include_tag('contacts', plugin: 'foton_contacts')
    end
  end
end