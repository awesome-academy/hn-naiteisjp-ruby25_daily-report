set :output, "log/cron.log"
set :environment, :development

# Every month, at: 1st, 5:00pm
every "0 17 1 * *" do
  rake "daily_reports:send_monthly_stats"
end
