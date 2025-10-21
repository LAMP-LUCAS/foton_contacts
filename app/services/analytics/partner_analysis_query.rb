module Analytics
  class PartnerAnalysisQuery
    def self.calculate(start_date: nil, end_date: nil)
      new(start_date, end_date).calculate
    end

    def initialize(start_date, end_date)
      @start_date = start_date
      @end_date = end_date || Date.today
    end

    def calculate
      company_ids = ContactEmployment.joins(contact: :issues)
                                     .where(issues: { created_on: @start_date..@end_date })
                                     .pluck(:company_id).uniq
      companies = FotonContact.where(id: company_ids)

      result = companies.map do |company|
        employees = company.employees.uniq
        next if employees.empty?

        {
          name: company.name,
          data: [{
            x: calculate_average_tenure(company),
            y: calculate_stability(company).round,
            r: employees.count
          }]
        }
      end.compact

      return result

    rescue => e
      Rails.logger.error "Error calculating Partner Analysis: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      return []
    end

    private

    def calculate_stability(company)
      return 100 unless @start_date

      initial_employments = Analytics::HistoricalStateQuery.records_at(company.employments_as_company, @start_date.prev_day)
      
      new_employments_count = company.employments_as_company.where(created_at: @start_date..@end_date).count

      ended_employments_count = Journal.where(journalized_type: 'ContactEmployment', notes: 'Destroyed')
                                       .where(journalized_id: initial_employments.ids)
                                       .where(created_on: @start_date..@end_date)
                                       .count

      base_size = initial_employments.count + new_employments_count
      return 100 if base_size.zero?

      turnover_rate = (ended_employments_count.to_f / base_size) * 100
      100 - turnover_rate
    end

    def calculate_average_tenure(company)
      active_employments = Analytics::HistoricalStateQuery.records_at(company.employments_as_company, @end_date)
      return 0 if active_employments.empty?

      total_tenure_days = active_employments.sum do |e|
        start = e.start_date || e.created_at.to_date
        (@end_date - start).to_i
      end

      (total_tenure_days.to_f / active_employments.size / 365).round(1)
    end
  end
end