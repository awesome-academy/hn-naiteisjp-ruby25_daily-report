class Manager::DepartmentsController < ApplicationController
  load_and_authorize_resource class: Department.name
  before_action :manager_user
  before_action :set_department

  def show
    return if @department.blank?

    @active_users_count = @department.users.active
                                     .not_manager
                                     .count
    @q = User.managed_by(current_user)
             .filter_by_active_status(active_status_param)
             .ransack params[:q]
    @pagy, @users = pagy(
      @q.result,
      limit: Settings.ITEMS_PER_PAGE_5
    )
  end

  private

  def active_status_param
    params.dig(:q, :active_eq) ||
      Settings.active_status.first
  end

  def set_department
    @department = current_user.department
  end
end
