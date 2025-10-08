module Analytics
  class AnalyticsController < ApplicationController
    before_action :authorize_global

    def index
      render template: 'analytics/index'
    end

    # Actions para os widgets do dashboard
    def irpa_widget
      contacts = Contact.person.includes(:issues)
      @irpa_data = Analytics::IrpaCalculator.calculate_for_collection(contacts)
      @irpa_data.sort_by! { |h| -h[:risk_score] }

      render partial: 'analytics/widgets/irpa_widget'
    end

    def data_quality_widget
      render plain: "Widget de Qualidade de Dados em construção..."
    end

    def partner_analysis_widget
      render plain: "Widget de Análise de Parceiros em construção..."
    end

    def team_performance
      @scorecard_data = Analytics::TeamScorecardQuery.calculate_all.compact.sort_by { |h| -h[:overall_score] }

      # Formata os dados para o Gráfico de Radar
      @chart_data = @scorecard_data.map do |data|
        {
          name: data[:group_name],
          data: {
            "Risco (Invertido)": 100 - data[:avg_risk_score],
            "Pontualidade": 100 - data[:aggregated_delay_rate],
            "Coesão (Normalizada)": (data[:cohesion_index_months] / 12.0).clamp(0, 1) * 100,
            "Score Geral": data[:overall_score]
          }
        }
      end

      render partial: 'analytics/widgets/team_performance'
    end

    def workload
      @start_date = Date.today.beginning_of_month
      @end_date = Date.today.end_of_month
      @date_range = (@start_date..@end_date).to_a
      
      @workload_data = Analytics::WorkloadQuery.calculate_for_period(@start_date, @end_date)
      @contacts = Contact.where(id: @workload_data.keys.map(&:id)).order(:name)

      render partial: 'analytics/widgets/workload'
    end

    def contact_details
      @contact = Contact.find(params[:id])
      @irpa_data = Analytics::IrpaCalculator.calculate_for_contact(@contact)
      render partial: 'analytics/widgets/details_modal'
    end

    def dynamic_dashboard
      scope = Contact.person.visible(User.current).includes(:issues)
      scope = scope.where(contact_type: params[:contact_type]) if params[:contact_type].present?
      scope = scope.where(status: params[:status]) if params[:status].present?
      if params[:search].present?
        search = "%#{params[:search].downcase}%"
        scope = scope.where('LOWER(name) LIKE ?', search)
      end

      @filtered_contacts = scope.all
      @irpa_data = Analytics::IrpaCalculator.calculate_for_collection(@filtered_contacts)
      
      @average_risk_score = if @irpa_data.any?
        (@irpa_data.sum { |h| h[:risk_score] } / @irpa_data.size).round(2)
      else
        0
      end

      render partial: 'analytics/widgets/dynamic_dashboard'
    end
  end
end
