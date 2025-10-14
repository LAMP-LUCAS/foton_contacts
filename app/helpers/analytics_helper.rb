module AnalyticsHelper
  def workload_hours_to_percentage(hours, contact)
    return 0 if hours.to_f.zero?

    default_hours = Setting.plugin_foton_contacts['default_workload_hours'].to_f
    available_hours = contact.available_hours_per_day.to_f > 0 ? contact.available_hours_per_day.to_f : default_hours

    return 0 if available_hours <= 0

    ((hours.to_f / available_hours) * 100).round
  end
end
