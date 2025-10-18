module FotonContactsRenderHelper
  def safe_render(options = {}, &block)
    begin
      render(options, &block)
    rescue => e
      Rails.logger.error "[FotonContacts] Erro ao renderizar a parcial '_#{options[:partial] || 'block'}': #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      
      # Em desenvolvimento, mostra um erro mais visível. Em produção, falha silenciosamente.
      if Rails.env.development?
        content_tag(:div, class: 'flash error') do
          concat(l(:error_rendering_partial, partial: options[:partial]))
          concat(content_tag(:pre, e.message, style: 'white-space: pre-wrap; margin-top: 10px;'))
        end
      else
        '' # Renderiza uma string vazia em produção
      end
    end
  end
end