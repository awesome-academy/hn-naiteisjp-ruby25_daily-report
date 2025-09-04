class MonthlyStatsMailerJob
  include Sidekiq::Job
  sidekiq_options retry: Settings.JOB_RETRY_TIMES

  def perform department_id
    department = Department.find_by id: department_id
    return unless department&.manager

    stats = ReportStatisticsService.new(department).generate_stats

    DepartmentReportMailer.monthly_stats_email(
      department.manager,
      department, stats
    ).deliver_now
  end
end
