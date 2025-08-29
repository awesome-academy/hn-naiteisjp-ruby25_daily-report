class Admin::DepartmentsController < ApplicationController
  before_action :admin_user
  before_action :filter_departments, only: :index
  before_action :find_department, only: %i(show edit update destroy)
  before_action :check_dependency_destroy_department, only: :destroy

  def index
    @pagy, @departments = pagy @departments, limit: Settings.ITEMS_PER_PAGE_10
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

  def find_department
    @department = Department.with_deleted.find_by id: params[:id]
    return if @department

    flash[:warning] = t("departments.index.table.no_result")
  end

  def filter_departments
    @departments = Department.with_deleted
                             .search_by_name(params[:query])
                             .order_by_latest
                             .with_status params[:deleted_at]
    return if @departments.present?

    flash[:warning] = t("departments.index.table.no_result")
  end

  def handle_status_change
    case department_params[:deleted_at].to_s
    when "1"
      @department.restore if @department.deleted?
    when "0"
      @department.destroy unless @department.deleted?
    end
  end
end
