require 'csv'

class Contact < ActiveRecord::Base
  include Redmine::SafeAttributes
  include Redmine::Acts::Customizable
  include Redmine::Acts::Attachable
  include Redmine::Acts::Searchable
  include Redmine::Acts::Event
  # include Redmine::I18n
  acts_as_customizable
  acts_as_attachable
  acts_as_searchable columns: %w(name email address description),
                     preload: [:author],
                     date_column: :created_at
  acts_as_event title: Proc.new { |o| "#{l(:label_contact)}: #{o.name}" },
                description: :description,
                datetime: :created_at,
                type: 'contact',
                url: Proc.new { |o| { controller: 'contacts', action: 'show', id: o.id } }
  
  belongs_to :author, class_name: 'User'
  belongs_to :project, optional: true
  belongs_to :user, optional: true
  
  has_many :roles, class_name: 'ContactRole', dependent: :destroy
  has_many :companies, through: :roles, source: :company
  has_many :inverse_roles, class_name: 'ContactRole', foreign_key: :company_id, dependent: :destroy
  has_many :employees, through: :inverse_roles, source: :contact
  
  has_many :group_memberships, class_name: 'ContactGroupMembership', dependent: :destroy
  has_many :groups, through: :group_memberships, source: :contact_group
  
  has_many :issue_links, class_name: 'ContactIssueLink', dependent: :destroy
  has_many :issues, through: :issue_links
  
  validates :name, presence: true
  enum contact_type: [:person, :company]
  enum status: [:active, :inactive, :discontinued]
  
  validates :contact_type, presence: true
  validates :status, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP, allow_blank: true }
  
  scope :persons, -> { where(contact_type: contact_types[:person]) }
  scope :companies, -> { where(contact_type: contact_types[:company]) }
  scope :active, -> { where(status: statuses[:active]) }
  scope :visible, ->(user) do
    if user&.admin?
      all
    else
      where(is_private: false).or(where(author_id: user&.id))
    end
  end
  
  safe_attributes 'name',
                 'email',
                 'phone',
                 'address',
                 'contact_type',
                 'status',
                 'is_private',
                 'project_id',
                 'description'

  def allowed_target_projects
    Project.allowed_to(User.current, :manage_contacts)
  end
  
  def company?
    contact_type == 'company'
  end
  
  def person?
    contact_type == 'person'
  end
  
  def active?
    status == 'active'
  end
  
  def attachments_visible?(user=User.current)
    visible?(user)
  end
  
  def attachments_editable?(user=User.current)
    visible?(user)
  end
  
  def notified_users
    []
  end
  
  def recipients
    notified_users.map(&:mail)
  end
  
  def visible?(user)
    return true if user&.admin?
    !is_private || author_id == user&.id
  end
  
  def to_s
    name
  end
  
  def css_classes
    [contact_type, status].join(' ')
  end

  def self.contacts_to_csv(contacts)
    CSV.generate(col_sep: ',') do |csv|
      csv << ["ID", "Name", "Email", "Phone", "Address", "Type", "Status", "Project", "Description"] # Header row
      contacts.each do |contact|
        csv << [
          contact.id,
          contact.name,
          contact.email,
          contact.phone,
          contact.address,
          contact.contact_type,
          contact.status,
          contact.project&.name, # Use & for safe navigation in case project is nil
          contact.description
        ]
      end
    end
  end
end
