class DepartmentReportMailer < ApplicationMailer
  def monthly_stats_email manager, department, stats
    @manager = manager
    @department = department
    @stats = stats
    @report_month = l Settings.LAST_MONTH, format: :month_year

    mail(
      to: @manager.email,
      subject: t(
        "monthly_report.subject",
        report_month: @report_month,
        department_name: @department.name
      )
    )
  end
end
