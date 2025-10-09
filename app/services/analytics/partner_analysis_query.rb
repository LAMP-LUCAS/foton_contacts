module Analytics
  class PartnerAnalysisQuery
    def self.calculate
      new.calculate
    end

    def calculate
      # Analyze companies that have employees linked to issues.
      companies = Contact.company.joins(employments_as_company: { contact: :issues }).distinct

      companies.map do |company|
        employees = company.employees.uniq
        next if employees.empty?

        # Stability (100 - Turnover Rate)
        ended_employments = company.employments_as_company.where.not(end_date: nil).count
        total_employments = company.employments_as_company.count
        turnover_rate = total_employments.zero? ? 0 : (ended_employments.to_f / total_employments) * 100
        stability = 100 - turnover_rate

        # Experience (Average tenure of current employees in years)
        active_employments = company.employments_as_company.where(end_date: nil)
        total_tenure_days = active_employments.sum { |e| (Date.today - e.start_date.to_date).to_i if e.start_date }
        avg_tenure_years = active_employments.empty? ? 0 : (total_tenure_days.to_f / active_employments.size / 365).round(1)

        {
          name: company.name,
          data: [{ x: avg_tenure_years, y: stability.round, r: employees.count }]
        }
      end.compact
    end
  end
end