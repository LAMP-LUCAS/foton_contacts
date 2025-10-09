module Analytics
  class WorkloadQuery
    def self.calculate(filters: {}, period: :month, date: Date.today)
      new(filters: filters, period: period, date: date).calculate
    end

    def initialize(filters:, period:, date:)
      @filters = filters
      @period = period
      @date = date
      @workload_data = Hash.new { |h, k| h[k] = Hash.new(0) }
      setup_date_range
    end

    def calculate
      contacts = get_filtered_contacts
      daily_workload = calculate_daily_workload(contacts)
      aggregated_data = aggregate_workload(daily_workload)
      summary_stats = calculate_summary(aggregated_data)

      {
        contacts: contacts,
        data: aggregated_data,
        summary: summary_stats,
        date_range: @date_range,
        period: @period
      }
    end

    private

    def setup_date_range
      case @period
      when :week
        @start_date = @date.beginning_of_week
        @end_date = @date.end_of_week
        @date_range = (@start_date..@end_date).to_a
      when :year
        @start_date = @date.beginning_of_year
        @end_date = @date.end_of_year
        @date_range = (@start_date..@end_date).map(&:beginning_of_month).uniq
      else # :month
        @start_date = @date.beginning_of_month
        @end_date = @date.end_of_month
        @date_range = (@start_date..@end_date).map(&:beginning_of_week).uniq
      end
    end

    def get_filtered_contacts
      scope = Contact.person.includes(:author, :project)
      scope = scope.where("LOWER(contacts.name) LIKE ?", "%#{@filters[:name].downcase}%") if @filters[:name].present?
      scope = scope.where(contact_type: @filters[:contact_type]) if @filters[:contact_type].present?
      # TODO: Add filters for company, group, and occupation level
      scope.order(:name)
    end

    def calculate_daily_workload(contacts)
      contact_ids = contacts.pluck(:id)
      issues = Issue.where.not(estimated_hours: nil)
                    .where("(start_date <= ? AND due_date >= ?)", @end_date, @start_date)
                    .joins(:contacts).where(contacts: { id: contact_ids })

      daily_hours = Hash.new { |h, k| h[k] = Hash.new(0) }

      issues.each do |issue|
        working_days = (issue.start_date..issue.due_date).count { |d| is_working_day?(d) }
        next if working_days.zero?
        hours_per_day = issue.estimated_hours.to_f / working_days

        issue.contacts.where(id: contact_ids).each do |contact|
          (issue.start_date..issue.due_date).each do |day|
            daily_hours[contact][day] += hours_per_day if day.between?(@start_date, @end_date) && is_working_day?(day)
          end
        end
      end
      convert_hours_to_percentage(daily_hours)
    end

    def convert_hours_to_percentage(daily_hours)
      default_hours = Setting.plugin_foton_contacts['default_workload_hours'].to_f
      return daily_hours if default_hours <= 0

      daily_hours.each do |contact, days|
        available_hours = contact.available_hours_per_day.to_f > 0 ? contact.available_hours_per_day.to_f : default_hours
        days.transform_values! { |hours| ((hours / available_hours) * 100).round if available_hours > 0 }
      end
      daily_hours
    end

    def aggregate_workload(daily_workload)
      return daily_workload if @period == :week

      agg_data = Hash.new { |h, k| h[k] = Hash.new(0) }
      daily_workload.each do |contact, days|
        days.each do |day, load|
          agg_key = (@period == :month) ? day.beginning_of_week : day.beginning_of_month
          agg_data[contact][agg_key] += load if load
        end
        # Average for the period
        total_load_for_contact = agg_data[contact].values.sum
        number_of_periods = agg_data[contact].keys.size
        avg_load = number_of_periods > 0 ? (total_load_for_contact / number_of_periods) : 0
        agg_data[contact][:average] = avg_load.round
      end
      agg_data
    end

    def calculate_summary(aggregated_data)
      all_loads = aggregated_data.values.flat_map(&:values).reject(&:nil?)
      return {} if all_loads.empty?

      {
        average: (all_loads.sum / all_loads.size).round,
        median: all_loads.sort[all_loads.size / 2].round
      }
    end

    def is_working_day?(date)
      (1..5).include?(date.wday)
    end
  end
end