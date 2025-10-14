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
      
      # Métricas para o Gráfico de Radar
      avg_tah = member_irpa_data.sum { |d| d[:tah_percent] } / @members.size
      avg_ir = member_irpa_data.sum { |d| d[:ir_percent] } / @members.size

      all_issues = @members.flat_map(&:issues).uniq
      closed_issues = all_issues.select { |i| i.status.is_closed? }
      
      aggregated_delay_rate = calculate_taa(closed_issues)
      cohesion_index = calculate_ice

      # Correção da fórmula do Score Geral para alinhar com bi_analysis_guide.md
      # Fórmula: (1 - IRPA Médio/100) * 0.4 + (1 - TAA/100) * 0.4 + (ICE em meses / 12) * 0.2
      # O resultado é uma pontuação de 0 a 1, que multiplicamos por 100 para a exibição.
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
        # Dados adicionados para o Gráfico de Radar
        avg_tah: avg_tah.round(2),
        avg_ir: avg_ir.round(2)
      }
    end

    private

    # Taxa de Atraso Agregada (TAA)
    def calculate_taa(closed_issues)
      return 0 if closed_issues.empty?
      late_issues_count = closed_issues.count { |i| i.due_date.present? && i.closed_on.present? && i.closed_on.to_date > i.due_date }
      (late_issues_count.to_f / closed_issues.count) * 100
    end

    # Índice de Coesão da Equipa (ICE)
    def calculate_ice
      total_membership_days = @group.memberships.sum do |membership|
        (Time.current.to_date - membership.created_at.to_date).to_i
      end
      (total_membership_days.to_f / @members.size) / 30.44 # Média de dias em um mês
    end
  end
end
