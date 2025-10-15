class AnalyticsController < ApplicationController
  helper :analytics
  helper :contacts
  helper Chartkick::Helper if Redmine::Plugin.installed?(:chartkick)
  before_action :authorize_global

  def index
    @tabs = get_analytics_tabs
  end

  def overview_tab
    contacts = Contact.person.includes(:issues)
    @irpa_data = Analytics::IrpaCalculator.calculate_for_collection(contacts)
    @irpa_data.sort_by! { |h| -h[:risk_score] }

    @quality_data = Analytics::DataQualityQuery.calculate
    @partner_data = Analytics::PartnerAnalysisQuery.calculate

    render partial: 'analytics/tabs/overview', locals: { irpa_data: @irpa_data, quality_data: @quality_data, partner_data: @partner_data }
  end

  def team_performance_tab
    @filter_params = params.permit(:period, :date, group_ids: [])
    @groups = ContactGroup.all
    @scorecard_data = Analytics::TeamScorecardQuery.calculate_all.compact.sort_by { |h| -h[:overall_score] }

    render partial: 'analytics/tabs/team_performance', locals: { scorecard_data: @scorecard_data }
  end

  def workload_tab
    @filter_params = params.permit(:period, :date, filters: [:name, :contact_type])
    # A carga inicial não precisa buscar dados, pois o frame `workload_results` fará isso.
    render partial: 'analytics/tabs/workload', locals: { filter_params: @filter_params }
  end

  def workload_results
    @filter_params = params.permit(:period, :date, filters: [:name, :contact_type, :project_id])
    period = @filter_params[:period]&.to_sym || :month
    date = @filter_params[:date].present? ? Date.parse(@filter_params[:date]) : Date.today

    @workload = Analytics::WorkloadQuery.calculate(
      filters: @filter_params[:filters] || {},
      period: period,
      date: date
    )
    render partial: 'analytics/components/workload_results', locals: { workload: @workload }
  end

  def team_details
    group = ContactGroup.find(params[:id])
    @scorecard_data = Analytics::TeamScorecardQuery.new(group).calculate
    render partial: 'analytics/components/team_details_card'
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

  private

  def get_analytics_tabs
    tabs = []
    tabs << { name: 'overview', partial: 'analytics/tabs/overview_frame', label: :label_overview }
    tabs << { name: 'team_performance', partial: 'analytics/tabs/team_performance_frame', label: :label_team_performance }
    tabs << { name: 'workload', partial: 'analytics/tabs/workload_frame', label: :label_workload }
    tabs
  end
end
