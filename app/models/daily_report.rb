class DailyReport < ApplicationRecord
  belongs_to :owner, class_name: User.name
  belongs_to :receiver, class_name: User.name

  enum status: Settings.daily_report_status.to_h, _prefix: true

  DAILY_REPORT_PARAMS = %w(receiver_id owner_id report_date
                           planned_tasks actual_tasks
                           incomplete_reason
                           next_day_planned_tasks).freeze
  MANAGER_NOTE_PARAM = :manager_notes
  DEPARTMENT_FILTER_PARAMS = %w(owner_id_eq report_date_eq status_eq).freeze

  def self.ransackable_attributes _auth_object = nil
    %w(actual_tasks created_at id incomplete_reason
        manager_notes next_day_planned_tasks owner_id
        planned_tasks receiver_id report_date
        reviewed_at status updated_at)
  end

  validates :planned_tasks, :actual_tasks, :next_day_planned_tasks,
            length: {minimum: Settings.MIN_LENGTH_TEXT_20}

  validates :report_date, presence: true
  validate :unique_report_per_day

  scope :order_created_at_desc, ->{order(created_at: :desc)}
  scope :by_status, lambda{|status|
    where(status:) if status.present? && statuses.key?(status)
  }
  scope :by_report_date, lambda{|date|
    where(report_date: date) if date.present?
  }
  scope :by_owner_id, ->(owner_id){where(owner_id:) if owner_id.present?}
  scope :filter_by_report_date, lambda{|report_date|
    where(report_date:) if report_date.present?
  }
  scope :filter_by_status, lambda{|status|
    where(status:) if status.present?
  }
  scope :filter_by_owner, lambda{|user_id|
    where(owner_id: user_id) if user_id.present?
  }
  scope :count_by_status_pending, lambda{|current_user|
    where(status: :pending, receiver: current_user).count
  }
  scope :in_month, lambda{|date|
    where(report_date: date.beginning_of_month..date.end_of_month)
  }

  private

  def unique_report_per_day
    return if report_date.blank? || owner_id.blank?

    existing = DailyReport.where(owner_id:, report_date:)
                          .where.not(id:)

    return unless existing.exists?

    errors.add(
      :report_date,
      :taken,
      message: I18n.t("daily_report.create.error_report_date")
    )
  end
end
