class User < ApplicationRecord
  devise :database_authenticatable, :recoverable,
         :registerable, :rememberable, :validatable

  has_one_attached :avatar do |attachable|
    attachable.variant :display,
                       resize_to_limit: Settings.IMAGE_RESIZE_TO_LIMIT_500_500
  end

  belongs_to :department, optional: true
  has_many :sent_reports,
           class_name: DailyReport.name,
           foreign_key: :owner_id,
           dependent: :destroy
  has_many :received_reports,
           class_name: DailyReport.name,
           foreign_key: :receiver_id,
           dependent: :nullify

  validates :name,
            presence: true,
            length: {maximum: Settings.MAX_LENGTH_USERNAME}

  validates :email,
            presence: true,
            format: {with: Rails.application.config.email_regex},
            length: {maximum: Settings.MAX_LENGTH_EMAIL},
            uniqueness: {
              case_sensitive: false,
              message: I18n.t("users.errors.email_already_exists")
            }
  validates :avatar,
            content_type: {
              in: %w(image/jpeg image/gif image/png),
              message: I18n.t("users.profile.avatar_type_error")
            },
            size: {
              less_than: Settings.IMAGE_SIZE_LARGE_LIMIT_5.megabytes
            }

  enum role: Settings.user_role.to_h
  delegate :name, to: :department, prefix: true
  delegate :manager, to: :department, allow_nil: true
  delegate :name, to: :manager, prefix: true, allow_nil: true

  validate :one_manager_per_department, if: :manager?

  USER_PARAMS = %w(name email role department_id active).freeze
  USER_PARAMS_WITH_PW = USER_PARAMS + %w(password).freeze
  PROFILE_PARAMS = %w(name phone_number address avatar).freeze

  def self.ransackable_attributes _auth_object = nil
    %w(email role department_id active)
  end

  def self.ransackable_associations _auth_object = nil
    %w(department received_reports sent_reports)
  end

  scope :not_admin, ->{where.not(role: :admin)}
  scope :not_manager, ->{where.not(role: :manager)}
  scope :active, ->{where(active: true)}
  scope :inactive, ->{where(active: false)}
  scope :filter_by_active_status, lambda {|status|
    case status
    when Settings.active_status.first
      active
    when Settings.active_status.last
      inactive
    else
      all
    end
  }
  scope :filter_by_role, ->(role){where(role:) if role.present?}
  scope :filter_by_department, lambda {|department_id|
    where(department_id:) if department_id.present?
  }
  scope :filter_by_email, lambda {|email|
    email.present? ? where("email LIKE ?", "%#{email}%") : all
  }
  scope :managed_by, lambda {|manager|
    manager.present? && where(department_id: manager.department_id, role: :user)
  }
  scope :unassigned_users, ->{where(department_id: nil, role: :user)}
  scope :get_staff_members, lambda {|manager|
    where(department_id: manager.department_id).where.not(id: manager.id)
  }
  scope :manager_count, ->{where(role: :manager).count}
  scope :user_count, ->{where(role: :user).count}
  scope :by_active, ->{order(active: :desc)}

  # gem devise
  def active_for_authentication?
    super && active?
  end

  # gem devise
  def inactive_message
    active? ? super : :inactive_account
  end

  private

  def one_manager_per_department
    return if department_id.blank?

    if User.where(department_id:, role: :manager).where.not(id:).exists?
      errors.add(:role, I18n.t("users.errors.one_manager_per_department"))
    end
  end
end
