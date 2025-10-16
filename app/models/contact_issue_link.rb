class ContactIssueLink < ActiveRecord::Base
  include Redmine::SafeAttributes
  include ActsAsJournalizedConcern
  include JournalizableDummiesConcern
  acts_as_journalized watch: ['role']

  belongs_to :issue
  belongs_to :contact, optional: true
  belongs_to :contact_group, optional: true

  validates :issue_id, presence: true
  validate :contact_or_group_present

  # The associated object (contact or group)
  def linked_object
    contact || contact_group
  end

  def to_s
    linked_object.to_s
  end

  def visible?(user = User.current)
    issue.visible?(user) && linked_object.try(:visible?, user)
  end

  private

  def contact_or_group_present
    if contact_id.blank? && contact_group_id.blank?
      errors.add(:base, :must_be_linked_to_contact_or_group)
    elsif contact_id.present? && contact_group_id.present?
      errors.add(:base, :cannot_be_linked_to_both_contact_and_group)
    end
  end
end
