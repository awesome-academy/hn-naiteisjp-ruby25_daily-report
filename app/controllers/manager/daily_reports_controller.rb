class Manager::DailyReportsController < ApplicationController
  load_and_authorize_resource class: DailyReport.name
  before_action :manager_user
  before_action :set_staff_members, only: :index

  def index
    @q = DailyReport.by_owner_id(@staff_members.pluck(:id))
                    .ransack params[:q]
    @pagy, @daily_reports = pagy(
      @q.result.includes(:owner).order_created_at_desc,
      items: Settings.ITEMS_PER_PAGE_10
    )
  end

  def edit; end

  def update
    if @daily_report.update daily_report_params
      flash[:success] = t "daily_report.update.success"
      redirect_to manager_daily_reports_path, status: :see_other
    else
      flash.now[:alert] = t "daily_report.update.failure"
      render :edit
    end
  end

  private

  def daily_report_params
    dr_params = params.require(:daily_report)
                      .permit DailyReport::MANAGER_NOTE_PARAM
    new_notes = dr_params[:manager_notes]&.strip
    old_notes = @daily_report.manager_notes&.strip
    dr_params[:status] = update_status new_notes, old_notes
    dr_params[:reviewed_at] = Time.current if dr_params[:status] != :pending
    dr_params
  end

  def set_staff_members
    @staff_members = User.get_staff_members current_user
  end

  def update_status new_notes, old_notes
    if new_notes.present? && new_notes != old_notes
      :commented
    elsif new_notes.blank? && old_notes.present?
      :read
    elsif new_notes == old_notes
      :commented
    else
      :read
    end
  end
end
