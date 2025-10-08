module Analytics
  class IrpaCalculator
    # Service object to calculate the Predictive Allocation Risk Index (IRPA)
    # IRPA = (TAH * 0.5) + (IR * 0.3) + (FCP * 0.2)

    def self.calculate_for_contact(contact)
      new(contact).calculate
    end

    def self.calculate_for_collection(contacts)
      contacts.map { |contact| new(contact).calculate }
    end

    def initialize(contact)
      @contact = contact
      @issues = @contact.issues.includes(:status, :tracker, :priority)
    end

    def calculate
      closed_issues = @issues.select { |i| i.status.is_closed? }
      open_issues = @issues.reject { |i| i.status.is_closed? }

      tah = calculate_tah(closed_issues)
      ir = calculate_ir(closed_issues)
      fcp = calculate_fcp(open_issues)

      risk_score = (tah * 0.5) + (ir * 0.3) + (fcp * 0.2)

      {
        contact_id: @contact.id,
        contact_name: @contact.name,
        risk_score: risk_score.round(2),
        tah_percent: tah.round(2),
        ir_percent: ir.round(2),
        fcp_avg: fcp.round(2)
      }
    end

    private

    # Taxa de Atraso Histórica (TAH)
    def calculate_tah(closed_issues)
      return 0 if closed_issues.empty?

      late_issues_count = closed_issues.count { |i| i.due_date.present? && i.closed_on.present? && i.closed_on.to_date > i.due_date }
      (late_issues_count.to_f / closed_issues.count) * 100
    end

    # Índice de Retrabalho (IR)
    def calculate_ir(closed_issues)
      return 0 if closed_issues.empty?

      # Assumes trackers named 'Bug' or 'Correction' signify rework.
      # This could be made configurable in the future.
      rework_trackers = ['Bug', 'Correction']
      rework_issues_count = closed_issues.count { |i| rework_trackers.include?(i.tracker.name) }
      (rework_issues_count.to_f / closed_issues.count) * 100
    end

    # Fator de Criticidade Ponderado (FCP)
    def calculate_fcp(open_issues)
      return 0 if open_issues.empty?

      # Higher position in Enumeration means higher priority
      total_priority_position = open_issues.sum { |i| i.priority.position }
      (total_priority_position.to_f / open_issues.count)
    end
  end
end
