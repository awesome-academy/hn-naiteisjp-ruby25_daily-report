class Admin::DepartmentsController < ApplicationController
  load_and_authorize_resource class: Department.name
  before_action :admin_user
  before_action :convert_status_param, only: :index
  before_action :check_dependency_destroy_department, only: :destroy

  def index
    @q = Department.with_deleted
                   .ransack params[:q]
    @pagy, @departments = pagy(
      @q.result.order_by_latest,
      limit: Settings.ITEMS_PER_PAGE_10
    )

    flash[:info] = t "departments.index.table.no_result" if @departments.empty?
  end

  def new
    @department = Department.new
  end

  def create
    @department = Department.new department_params
    if @department.save
      flash[:success] = t "departments.new.created_successfully"
      redirect_to admin_department_path(@department)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @department.update department_params
      handle_status_change

      flash[:success] = t "departments.edit.updated_successfully"
      redirect_to admin_departments_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def show; end

  def destroy
    if !@department.deleted? && @department.destroy
      flash[:success] = t "departments.destroy.success"
    else
      flash[:danger] = t "departments.destroy.fail"
    end
    redirect_to admin_departments_path, status: :see_other
  end

  private

  def department_params
    params.require(:department).permit Department::DEPARTMENT_PARAMS
  end

  def check_dependency_destroy_department
    return if @department.users.blank?

    flash[:danger] = t "departments.errors.has_users"
    redirect_to admin_departments_path, status: :see_other
  end

  def handle_status_change
    case department_params[:deleted_at].to_s
    when Settings.be_one
      @department.restore if @department.deleted?
    when Settings.be_zero
      @department.destroy unless @department.deleted?
    end
  end

  def convert_status_param
    status = params.dig(:q, :deleted_at_eq)
    return if status.blank?

    if status == Settings.active_status.first
      params[:q][:deleted_at_null] = true
    elsif status == Settings.active_status.last
      params[:q][:deleted_at_not_null] = true
    end

    params[:q].delete(:deleted_at_eq)
  end
end
