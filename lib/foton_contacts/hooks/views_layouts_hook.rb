module FotonContacts
  module Hooks
    class ViewsLayoutsHook < Redmine::Hook::ViewListener
      def view_layouts_base_html_head(context = {})
        stylesheet_link_tag('contacts', plugin: 'foton_contacts') +
        javascript_include_tag('contacts', plugin: 'foton_contacts')
      end
      
      def view_issues_show_description_bottom(context = {})
        issue = context[:issue]
        controller = context[:controller]
        return unless issue && controller
        
        links = issue.contact_issue_links.includes(:contact).where(contacts: { status: 'active' })
        return if links.empty?
        
        controller.render_to_string(
          partial: 'contact_issue_links/list',
          locals: { issue: issue, links: links }
        )
      end
      
      def view_projects_show_sidebar_bottom(context = {})
        project = context[:project]
        controller = context[:controller]
        return unless project && controller
        
        contacts = Contact.active.where(project_id: project.id).limit(5)
        return if contacts.empty?
        
        controller.render_to_string(
          partial: 'contacts/project_sidebar',
          locals: { project: project, contacts: contacts }
        )
      end
    end
  end
end