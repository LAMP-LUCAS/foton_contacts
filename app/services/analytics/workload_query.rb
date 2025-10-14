module Analytics
  class WorkloadQuery
    # CALCULA A CARGA DE TRABALHO PARA CONTATOS, SEPARANDO CARGA INDIVIDUAL E DE GRUPO

    def self.calculate(filters: {}, period: :month, date: Date.today)
      new(filters: filters, period: period, date: date).calculate
    end

    def initialize(filters:, period:, date:)
      @filters = filters
      @period = period.to_sym
      @date = date
      setup_date_range
    end

    def calculate
      contacts = get_filtered_contacts
      daily_hours = calculate_daily_hours(contacts)

      final_data = if @period == :week
                     daily_hours
                   else
                     aggregate_workload(daily_hours)
                   end

      {
        contacts: contacts,
        data: final_data,
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
      scope = Contact.person.includes(:contact_groups)
      scope = scope.where("LOWER(contacts.name) LIKE ?", "%#{@filters[:name].downcase}%") if @filters[:name].present?
      scope.order(:name)
    end

    def calculate_daily_hours(contacts)
      workload_hours = Hash.new { |h, k| h[k] = Hash.new { |h2, k2| h2[k2] = { individual: 0.0, group: 0.0 } } }
      contact_ids = contacts.map(&:id)

      issues = Issue.where.not(estimated_hours: nil)
                    .where("issues.start_date <= ? AND issues.due_date >= ?", @end_date, @start_date)
                    .joins("LEFT JOIN contact_issue_links ON contact_issue_links.issue_id = issues.id")
                    .where("contact_issue_links.contact_id IN (?)", contact_ids)
                    .distinct.includes(:contacts, :contact_groups)

      issues.each do |issue|
        distribute_hours_for_issue(issue, contacts, workload_hours)
      end

      workload_hours
    end

    def distribute_hours_for_issue(issue, contacts, workload_hours)
      working_days = (issue.start_date..issue.due_date).count { |d| is_working_day?(d) }
      return if working_days.zero?
      hours_per_day = issue.estimated_hours.to_f / working_days

      (issue.start_date..issue.due_date).each do |day|
        next unless day.between?(@start_date, @end_date) && is_working_day?(day)

        direct_contacts_in_issue = issue.contacts.where(id: contacts.map(&:id))
        
        contacts.each do |contact|
          is_direct = direct_contacts_in_issue.include?(contact)
          is_in_group = contact.contact_groups.any? { |cg| issue.contact_groups.include?(cg) }

          if is_direct
            workload_hours[contact][day][:individual] += hours_per_day
          elsif is_in_group
            workload_hours[contact][day][:group] += hours_per_day
          end
        end
      end
    end

    def aggregate_workload(daily_workload)
      agg_data = Hash.new { |h, k| h[k] = Hash.new { |h2, k2| h2[k2] = { individual: 0.0, group: 0.0, count: 0 } } }

      daily_workload.each do |contact, days|
        days.each do |day, loads|
          agg_key = (@period == :month) ? day.beginning_of_week : day.beginning_of_month
          next unless @date_range.include?(agg_key)

          agg_data[contact][agg_key][:individual] += loads[:individual]
          agg_data[contact][agg_key][:group] += loads[:group]
          agg_data[contact][agg_key][:count] += 1 if (loads[:individual] + loads[:group]) > 0
        end
      end

      agg_data.each do |contact, periods|
        periods.each do |period_key, data|
          count = data[:count].to_f
          if count > 0
            data[:individual] = (data[:individual] / count)
            data[:group] = (data[:group] / count)
          end
        end
      end
      agg_data
    end

    def is_working_day?(date)
      (1..5).include?(date.wday)
    end
  end
end
