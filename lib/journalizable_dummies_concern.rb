# frozen_string_literal: true

# Concern to add dummy methods to models that are journalized
# but do not have all the features of a full Redmine object like an Issue.
# This prevents NoMethodError crashes when the Journal or Mailer systems
# try to call methods that don't exist on simple models.
module JournalizableDummiesConcern
  extend ActiveSupport::Concern

  # Called by Journal#initialize
  def custom_field_values
    []
  end

  # Called by Journal#notified_users and Mailer
  def notified_users
    []
  end

  # Called by Journal#notified_users and Mailer
  def notified_watchers
    []
  end

  # Called by Mailer
  def recipients
    []
  end

  # Called by Mailer
  def notified_mentions
    []
  end
end