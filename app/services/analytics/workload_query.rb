module Analytics
  class WorkloadQuery
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

      if @filters[:analysis_type] == 'spent'
        final_data = calculate_spent_hours(contacts)
      else
        final_data = calculate_daily_hours(contacts)
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
      when :custom
        @start_date = @date
        @end_date = @filters[:end_date]
        @date_range = (@start_date..@end_date).to_a
      else # :month
        @start_date = @date.beginning_of_month
        @end_date = @date.end_of_month
        @date_range = (@start_date..@end_date).map(&:beginning_of_week).uniq
      end
    end

    def get_filtered_contacts
      scope = FotonContact.person.includes(:contact_groups)
      scope = scope.where("LOWER(foton_contacts.name) LIKE ?", "%#{@filters[:name].downcase}%") if @filters[:name].present?
      scope.order(:name)
    end

    def calculate_daily_hours(contacts)
      workload_hours = Hash.new { |h, k| h[k] = Hash.new { |h2, k2| h2[k2] = { individual: 0.0, group: 0.0 } } }
      return {} if contacts.empty?

      contact_ids = contacts.map(&:id)
      group_ids = ContactGroupMembership.where(contact_id: contact_ids).pluck(:contact_group_id).uniq

      issues = Issue.where.not(estimated_hours: nil)
                    .where("issues.start_date <= ? AND issues.due_date >= ?", @end_date, @start_date)
                    .joins("LEFT JOIN contact_issue_links ON contact_issue_links.issue_id = issues.id")
                    .where("contact_issue_links.contact_id IN (?) OR contact_issue_links.contact_group_id IN (?)", contact_ids, group_ids)
                    .distinct.includes(:contacts, :contact_groups)

      issues = issues.where(project_id: @filters[:project_id]) if @filters[:project_id].present?

      issues.each do |issue|
        distribute_hours_for_issue(issue, contacts, workload_hours)
      end

      workload_hours
    end

    def calculate_spent_hours(contacts)
      workload_hours = Hash.new { |h, k| h[k] = Hash.new { |h2, k2| h2[k2] = { individual: 0.0, group: 0.0 } } }
      return {} if contacts.empty?

      contact_user_map = contacts.where.not(user_id: nil).pluck(:id, :user_id).to_h
      user_ids = contact_user_map.values
      return {} if user_ids.empty?

      time_entries = TimeEntry.where(user_id: user_ids)
                              .where(spent_on: @start_date..@end_date)

      if @filters[:project_id].present?
        project_ids = [@filters[:project_id]] + Project.find(@filters[:project_id]).descendants.pluck(:id)
        time_entries = time_entries.where(project_id: project_ids)
      end

      user_contact_map = contact_user_map.invert

      time_entries.group(:spent_on, :user_id).sum(:hours).each do |(spent_on, user_id), hours|
        contact_id = user_contact_map[user_id]
        if contact_id
          workload_hours[contact_id][spent_on.to_s][:individual] += hours.to_f
        end
      end

      workload_hours
    end

    def distribute_hours_for_issue(issue, contacts, workload_hours)
      # Calcular dias úteis totais da issue
      total_working_days = (issue.start_date..issue.due_date).count { |d| is_working_day?(d) }
      return if total_working_days.zero?
      
      hours_per_day = issue.estimated_hours.to_f / total_working_days

      direct_contacts_in_issue = issue.contacts.where(id: contacts.map(&:id))

      # Distribuir horas apenas pelos dias dentro do período visível
      (issue.start_date..issue.due_date).each do |day|
        next unless day.between?(@start_date, @end_date) && is_working_day?(day)

        direct_contacts_in_issue.each do |contact|
          workload_hours[contact.id][day.to_s][:individual] += hours_per_day
        end

        issue.contact_groups.each do |group|
          group.contacts.where(id: contacts.map(&:id)).each do |contact|
            next if direct_contacts_in_issue.include?(contact)
            workload_hours[contact.id][day.to_s][:group] += hours_per_day
          end
        end
      end
    end

    def is_working_day?(date)
      (1..5).include?(date.wday)
    end
  end
end