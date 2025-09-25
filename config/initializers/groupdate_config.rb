# frozen_string_literal: true

# Define o timezone padrão do ActiveRecord como :utc, um requisito da gem 'groupdate'.
# Isso garante consistência ao agrupar registros por data nos gráficos de análise.
Rails.application.config.active_record.default_timezone = :utc