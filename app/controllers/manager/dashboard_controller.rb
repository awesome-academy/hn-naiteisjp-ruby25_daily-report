class Manager::DashboardController < ApplicationController
  before_action :manager_user
  before_action :set_department

  def show
    return if @department.blank?

    @active_users_count = @department.users.active.not_manager.count
    @pending_reports_count = DailyReport.count_by_status_pending current_user
  end

  private

  def set_department
    @department = current_user.department
  end
end
