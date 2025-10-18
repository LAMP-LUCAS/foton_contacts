module AnalyticsHelper
  include ApplicationHelper
  def irpa_status_data(score)
    # Garante que o score seja um número para a comparação
    score_f = score.to_f

    level, text = case score_f
                  when 0..40
                    ['success', l(:label_foton_contacts_low_risk)]
                  when 40..75
                    ['warning', l(:label_foton_contacts_medium_risk)]
                  else
                    ['danger', l(:label_foton_contacts_high_risk)]
                  end

    { level: level, text: text }
  end
end