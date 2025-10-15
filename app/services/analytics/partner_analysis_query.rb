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
      # Analisa empresas que tiveram funcionários vinculados a tarefas no período.
      company_ids = ContactEmployment.joins(contact: :issues)
                                     .where(issues: { created_on: @start_date..@end_date })
                                     .pluck(:company_id).uniq
      companies = Contact.where(id: company_ids)

      result = companies.map do |company|
        employees = company.employees.uniq
        next if employees.empty?

        stability = calculate_stability(company)
        avg_tenure_years = calculate_average_tenure(company)

        {
          name: company.name,
          data: [{ x: avg_tenure_years, y: stability.round, r: employees.count }]
        }
      end.compact

      return result

    rescue => e
      Rails.logger.error "Error calculating Partner Analysis: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      return [] # Retorna um array vazio em caso de erro para não quebrar a view
    end

    private

    def calculate_stability(company)
      # Usa JOIN explícito para corrigir o erro de tabela indefinida
      base_query = Journal.joins("INNER JOIN contact_employments ON contact_employments.id = journals.journalized_id AND journals.journalized_type = 'ContactEmployment'")
                          .where(contact_employments: { company_id: company.id })

      # Vínculos que já existiam no início do período
      initial_employments_query = base_query.where("journals.created_on < ?", @start_date)
      initial_employments = initial_employments_query.group(:journalized_id)
                                                   .having("SUM(CASE WHEN notes = 'Destroyed' THEN 1 ELSE -1 END) < 0")
                                                   .pluck(:journalized_id)

      # Vínculos criados durante o período
      new_employments = base_query.where(notes: 'Created', created_on: @start_date..@end_date).count

      # Vínculos terminados durante o período
      ended_employments = base_query.where(notes: 'Destroyed', journalized_id: initial_employments, created_on: @start_date..@end_date).count

      base_size = initial_employments.size + new_employments
      return 100 if base_size.zero?

      turnover_rate = (ended_employments.to_f / base_size) * 100
      100 - turnover_rate
    end

    def calculate_average_tenure(company)
      # Vínculos que estavam ativos no final do período
      active_employment_ids = Journal.joins("INNER JOIN contact_employments ON contact_employments.id = journals.journalized_id AND journals.journalized_type = 'ContactEmployment'")
                                     .where(contact_employments: { company_id: company.id })
                                     .where("journals.created_on <= ?", @end_date)
                                     .group(:journalized_id)
                                     .having("SUM(CASE WHEN notes = 'Destroyed' THEN 1 ELSE -1 END) < 0")
                                     .pluck(:journalized_id)

      active_employments = ContactEmployment.where(id: active_employment_ids)
      return 0 if active_employments.empty?

      total_tenure_days = active_employments.sum do |e|
        start = e.start_date || e.created_at.to_date
        (@end_date - start).to_i
      end

      (total_tenure_days.to_f / active_employments.size / 365).round(1)
    end
  end
end