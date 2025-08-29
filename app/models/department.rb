class Department < ApplicationRecord
  acts_as_paranoid

  belongs_to :manager, class_name: User.name, optional: true

  has_many :users, dependent: :nullify
  has_many :daily_reports, through: :users, source: :sent_reports

  validates :name, presence: true, uniqueness: {case_sensitive: false}
  validates :description,
            presence: true,
            length: {minimum: Settings.MIN_LENGTH_DESCRIPTION_10}

  DEPARTMENT_PARAMS = %w(name description deleted_at).freeze

  scope :order_by_latest, ->{order(deleted_at: :asc, created_at: :desc)}
  scope :order_by_name, ->{order(name: :desc)}
  scope :search_by_name, lambda {|query|
    where("name LIKE ?", "%#{query.strip}%") if query.present?
  }
  scope :with_department_id, ->(id){where(id:)}

  scope :active, ->{where(deleted_at: nil)}
  scope :inactive, ->{where.not(deleted_at: nil)}

  scope :with_status, lambda {|status|
    case status
    when "active"
      active
    when "inactive"
      inactive
    else
      all
    end
  }
end
