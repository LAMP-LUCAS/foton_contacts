module Analytics
  class TeamScorecardQuery
    def self.calculate_all
      ContactGroup.all.map do |group|
        new(group).calculate
      end
    end

    def initialize(group)
      @group = group
      @members = @group.contacts.person.includes(issues: [:status, :tracker, :priority])
    end

    def calculate
      return nil if @members.empty?

      member_irpa_data = Analytics::IrpaCalculator.calculate_for_collection(@members)
      avg_risk_score = member_irpa_data.sum { |d| d[:risk_score] } / @members.size
      
      avg_tah = member_irpa_data.sum { |d| d[:tah_percent] } / @members.size
      avg_ir = member_irpa_data.sum { |d| d[:ir_percent] } / @members.size

      all_issues = @members.flat_map(&:issues).uniq
      closed_issues = all_issues.select { |i| i.status.is_closed? }
      
      aggregated_delay_rate = calculate_taa(closed_issues)
      cohesion_index = calculate_ice

      score = (1 - avg_risk_score / 100.0) * 0.4 + \
              (1 - aggregated_delay_rate / 100.0) * 0.4 + \
              (cohesion_index / 12.0).clamp(0, 1) * 0.2
      overall_score = score * 100

      {
        group_id: @group.id,
        group_name: @group.name,
        avg_risk_score: avg_risk_score.round(2),
        aggregated_delay_rate: aggregated_delay_rate.round(2),
        cohesion_index_months: cohesion_index.round(1),
        overall_score: overall_score.round(2),
        avg_tah: avg_tah.round(2),
        avg_ir: avg_ir.round(2)
      }
    rescue => e
      Rails.logger.error "Error calculating Team Scorecard for group #{@group.id}: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      nil # Retorna nil para que o chamador possa filtrar grupos com erro
    end

    private

    def calculate_taa(closed_issues)
      return 0 if closed_issues.empty?
      late_issues_count = closed_issues.count { |i| i.due_date.present? && i.closed_on.present? && i.closed_on.to_date > i.due_date }
      (late_issues_count.to_f / closed_issues.count) * 100
    end

    # Índice de Coesão da Equipa (ICE) - Refatorado com Journals
    def calculate_ice
      membership_journals = Journal.where(journalized_type: 'ContactGroupMembership', journalized_id: @group.memberships.ids)
                                   .select(:journalized_id, :notes, :created_on)
                                   .order(:created_on)

      # Agrupa os eventos de criação e destruição por cada vínculo
      events_by_membership = membership_journals.group_by(&:journalized_id)

      total_membership_days = events_by_membership.sum do |_, events|
        creation_event = events.find { |e| e.notes == 'Created' }
        next 0 unless creation_event

        destruction_event = events.find { |e| e.notes == 'Destroyed' }
        
        start_date = creation_event.created_on.to_date
        end_date = destruction_event ? destruction_event.created_on.to_date : Date.today

        (end_date - start_date).to_i
      end

      return 0 if @members.size.zero?
      (total_membership_days.to_f / @members.size) / 30.44 # Média de dias em um mês
    end
  end
end
