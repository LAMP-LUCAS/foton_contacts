module Analytics
  class WorkloadCheckerService
    def self.call(contact_id:, issue_start_date:, issue_due_date:, issue_estimated_hours:)
      new(contact_id, issue_start_date, issue_due_date, issue_estimated_hours).call
    end

    def initialize(contact_id, issue_start_date, issue_due_date, issue_estimated_hours)
      @contact = Contact.find(contact_id)
      @issue_start_date = issue_start_date
      @issue_due_date = issue_due_date
      @issue_estimated_hours = issue_estimated_hours.to_f
    end

    def call
      # 1. Get existing workload for the contact in the given period
      workload_data = Analytics::WorkloadQuery.calculate(
        filters: { contact_ids: [@contact.id], end_date: @issue_due_date },
        period: :custom, # Custom period
        date: @issue_start_date # Start date of custom period
      )

      # 2. Calculate the daily hours for the new task, considering only working days
      working_days = (@issue_start_date..@issue_due_date).count { |d| (1..5).include?(d.wday) }
      daily_hours_for_new_task = working_days > 0 ? @issue_estimated_hours / working_days : 0

      # 3. Check each day for overload
      overloaded = false
      (@issue_start_date..@issue_due_date).each do |day|
        next unless (1..5).include?(day.wday) # Skip weekends

        existing_hours = workload_data[:data].dig(@contact.id, day.to_s, :individual).to_f + workload_data[:data].dig(@contact.id, day.to_s, :group).to_f
        total_hours_on_day = existing_hours + daily_hours_for_new_task

        if total_hours_on_day > (@contact.available_hours_per_day || Setting.plugin_foton_contacts[:default_workload_hours].to_f)
          overloaded = true
          break
        end
      end

      if overloaded
        { status: 'overload', message: I18n.t(:warning_contact_overload, name: @contact.name) }
      else
        { status: 'ok' }
      end
    rescue => e
      Rails.logger.error "Error in WorkloadCheckerService for contact #{@contact.id}: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      { status: 'error', message: I18n.t(:error_workload_check) }
    end
  end
end
