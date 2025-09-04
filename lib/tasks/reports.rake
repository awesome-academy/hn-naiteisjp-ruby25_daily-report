namespace :daily_reports do
  desc "Dispatch jobs to send monthly report statistics to managers"
  task send_monthly_stats: :environment do
    Department.includes(:manager).find_each do |department|
      MonthlyStatsMailerJob.perform_async(department.id) if department.manager
    end
  end
end
