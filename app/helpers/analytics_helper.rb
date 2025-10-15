# analytics_helper.rb
module AnalyticsHelper
  def workload_hours_to_percentage(hours, contact)
    return 0 if hours.to_f.zero?

    # Usar horas disponíveis do contato ou valor padrão
    available_hours = if contact.available_hours_per_day.to_f > 0
                        contact.available_hours_per_day.to_f
                      else
                        default_hours = Setting.plugin_foton_contacts&.[]('default_workload_hours').to_f
                        default_hours > 0 ? default_hours : 8.0
                      end

    return 0 if available_hours <= 0

    percentage = (hours.to_f / available_hours) * 100
    
    # Limitar a 2 casas decimais para evitar números muito longos
    (percentage * 100).round / 100.0
  end

  # Calcula o número de dias úteis em um determinado mês,
  # respeitando as configurações de dias não úteis do Redmine.
  def working_days_in_month(date)
    start_of_month = date.beginning_of_month
    end_of_month = date.end_of_month
    
    # Obtém os dias da semana não úteis das configurações do Redmine (ex: [6, 7] para sab/dom)
    # O padrão é sábado e domingo se não estiver configurado.
    non_working_days = Setting.non_working_week_days.map(&:to_i)
    non_working_days = [6, 0] if non_working_days.empty? # Ruby's wday is 0 for Sunday

    (start_of_month..end_of_month).count do |day|
      !non_working_days.include?(day.wday)
    end
  end
  
  def project_tree_array(projects)
    ary = []
    project_tree(projects) do |project, level|
      name_prefix = (level > 0 ? ('&nbsp;' * 2 * level + '&#187; ').html_safe : '')
      ary << [name_prefix + project.name, project.id]
    end
    ary
  end
end
