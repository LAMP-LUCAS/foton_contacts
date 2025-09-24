class Contact < ActiveRecord::Base
  include Redmine::SafeAttributes
  
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
  validates :contact_type, presence: true, inclusion: { in: %w(person company) }
  validates :status, presence: true, inclusion: { in: %w(active inactive discontinued) }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP, allow_blank: true }
  
  scope :persons, -> { where(contact_type: 'person') }
  scope :companies, -> { where(contact_type: 'company') }
  scope :active, -> { where(status: 'active') }
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
end