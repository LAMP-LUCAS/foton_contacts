module Hooks
  class ViewsLayoutsHook < Redmine::Hook::ViewListener
    def view_layouts_base_html_head(context = {})
      # 1. Inclui o JavaScript Global do Redmine (agora com Hotwire)
      tags = context[:controller].view_context.javascript_include_tag(
        'application', 
        type: 'module' # Força o carregamento como módulo JavaScript
      )
      
      # '<script src="https://cdn.jsdelivr.net/npm/@hotwired/turbo@8.0.4/dist/turbo.es2017-umd.js" type="module"></script>',
      # '<script src="https://cdn.jsdelivr.net/npm/@hotwired/stimulus@3.2.2/dist/stimulus.min.js" type="module"></script>',
      

      # 2. Inclui o CSS do seu plugin
      tags << context[:controller].view_context.stylesheet_link_tag(
        'contacts', 
        plugin: 'foton_contacts'
      )

      # 3. Inclui o JavaScript do seu plugin (se necessário)
      # Use um arquivo diferente para evitar confusão. Ex: 'foton_contacts'
      tags << context[:controller].view_context.javascript_include_tag(
        'foton_contacts', 
        plugin: 'foton_contacts'
      )

      tags.join("\n").html_safe
    end
  end
end
  