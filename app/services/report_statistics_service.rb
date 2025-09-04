class ReportStatisticsService
  def initialize department
    @department = department
    @staff_members = @department.users.not_manager
    @last_month = Settings.LAST_MONTH.all_month
  end

  def generate_stats
    stats = initialize_stats_hash

    reports_in_month.each do |report|
      accumulate_report_data stats[report.owner], report
    end

    stats
  end

  private

  def initialize_stats_hash
    @staff_members.index_with do |_staff|
      {total: 0}.merge(DailyReport.statuses.keys.index_with{0})
    end
  end

  def reports_in_month
    DailyReport.where owner: @staff_members, report_date: @last_month
  end

  def accumulate_report_data staff_stats, report
    return unless staff_stats

    staff_stats[:total] += 1
    staff_stats[report.status] += 1
  end
end
