class User < ApplicationRecord
  attr_accessor :remember_token

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
            uniqueness: {case_sensitive: false}

  validates :password,
            presence: true,
            length:   {
              minimum: Settings.MIN_LENGTH_PASSWORD,
              message: I18n.t("users.errors.password_length",
                              count: Settings.MIN_LENGTH_PASSWORD)
            },
            allow_nil: true

  has_secure_password

  enum role: Settings.user_role.to_h
  delegate :name, to: :department, prefix: true
  delegate :manager, to: :department, allow_nil: true
  delegate :name, to: :manager, prefix: true, allow_nil: true

  USER_PARAMS = %w(name email role department_id).freeze

  scope :filter_by_role, ->(role){where(role:) if role.present?}
  scope :filter_by_department, lambda {|department_id|
    where(department_id:) if department_id.present?
  }
  scope :filter_by_email, lambda {|email|
    where("email LIKE ?", "%#{email}%") if email.present?
  }
  scope :managed_by, lambda {|manager|
    manager.present? && where(department_id: manager.department_id)
  }
  scope :unassigned_users, ->{where(department_id: nil, role: :user)}
  scope :get_staff_members, lambda {|manager|
    where(department_id: manager.department_id).where.not(id: manager.id)
  }

  class << self
    def digest string
      cost = if ActiveModel::SecurePassword.min_cost
               BCrypt::Engine::MIN_COST
             else
               BCrypt::Engine.cost
             end
      BCrypt::Password.create string, cost:
    end

    def new_token
      SecureRandom.urlsafe_base64
    end
  end

  def remember
    self.remember_token = User.new_token
    update_attribute :remember_digest, User.digest(remember_token)
    remember_digest
  end

  def session_token
    remember_digest || remember
  end

  def authenticated? attribute, token
    digest = send("#{attribute}_digest")
    return false if digest.nil?

    BCrypt::Password.new(digest).is_password? token
  end

  def forget
    update_attribute :remember_digest, nil
  end
end
