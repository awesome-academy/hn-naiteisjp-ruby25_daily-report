class User::DailyReportsController < ApplicationController
  load_and_authorize_resource class: DailyReport.name
  before_action :check_user_role
  before_action :belongs_department?, except: %i(index)
  before_action :check_status, only: :edit

  def new
    @daily_report = current_user.sent_reports.build
  end

  def create
    @daily_report = current_user.sent_reports.build daily_report_params

    if @daily_report.save
      DailyReportMailer.notify_manager(@daily_report).deliver_later

      flash[:success] = t "daily_report.create.success"
      redirect_to user_daily_reports_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def index
    @q = current_user.sent_reports
                     .ransack params[:q]

    @pagy, @daily_reports = pagy(
      @q.result.order_created_at_desc,
      limit: Settings.ITEMS_PER_PAGE_10
    )
  end

  def show; end

  def edit; end

  def update
    if @daily_report.update daily_report_params
      flash[:success] = t "daily_report.update.success"
      redirect_to user_daily_reports_path, status: :see_other
    else
      flash.now[:danger] = t "daily_report.update.failure"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @daily_report.status_pending?
      @daily_report.destroy
      flash[:success] = t "daily_report.delete.success"
    else
      flash[:danger] = t "daily_report.delete.forbidden_status"
    end

    redirect_to user_daily_reports_path, status: :see_other
  end

  private

  def daily_report_params
    params.require(:daily_report).permit DailyReport::DAILY_REPORT_PARAMS
  end

  def check_status
    return unless @daily_report.status_read?

    flash[:danger] = t "daily_report.edit.forbidden_status"
    redirect_to user_daily_reports_path, status: :see_other
  end

  def belongs_department?
    return if current_user.department_id.present?

    flash[:danger] = t "departments.edit.forbidden_department"
    redirect_to user_daily_reports_path, status: :see_other
  end
end
