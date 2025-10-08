module Analytics
  class WorkloadQuery
    def self.calculate_for_period(start_date, end_date)
      new(start_date, end_date).calculate
    end

    def initialize(start_date, end_date)
      @start_date = start_date.to_date
      @end_date = end_date.to_date
      @workload_data = Hash.new { |h, k| h[k] = Hash.new(0) }
    end

    def calculate
      issues = Issue.where.not(estimated_hours: nil)
                    .where("(start_date <= ? AND due_date >= ?)", @end_date, @start_date)

      issues.each do |issue|
        distribute_issue_workload(issue)
      end

      convert_hours_to_percentage
      @workload_data
    end

    private

    def distribute_issue_workload(issue)
      return if issue.estimated_hours.to_f <= 0

      issue_start = issue.start_date.to_date
      issue_end = issue.due_date.to_date
      
      # Consider only the part of the issue within the query period
      period_start = [@start_date, issue_start].max
      period_end = [@end_date, issue_end].min

      working_days = (period_start..period_end).count { |d| is_working_day?(d) }
      return if working_days == 0

      hours_per_day = issue.estimated_hours.to_f / working_days

      issue.contacts.person.each do |contact|
        (period_start..period_end).each do |day|
          @workload_data[contact][day] += hours_per_day if is_working_day?(day)
        end
      end
    end

    def convert_hours_to_percentage
      default_hours = Setting.plugin_foton_contacts['default_workload_hours'].to_f
      return if default_hours <= 0

      @workload_data.each do |contact, daily_hours|
        available_hours = contact.available_hours_per_day.to_f > 0 ? contact.available_hours_per_day.to_f : default_hours
        daily_hours.transform_values! do |hours|
          ((hours / available_hours) * 100).round(1)
        end
      end
    end

    def is_working_day?(date)
      # Simple implementation: Monday to Friday. Redmine may have a more complex setting.
      (1..5).include?(date.wday)
    end
  end
end
