class Admin::DepartmentsController < ApplicationController
  before_action :logged_in_user, :admin_user
  before_action :load_department, only: %i(show edit update destroy)
  before_action :filter_departments, only: :index
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
      flash[:success] = t "departments.edit.updated_successfully"
      redirect_to admin_department_path @department
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def show; end

  def destroy
    if @department.destroy
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

  def load_department
    @department = Department.find_by id: params[:id]
    return if @department

    flash[:danger] = t "departments.errors.not_found"
    redirect_to admin_departments_path, status: :see_other
  end

  def check_dependency_destroy_department
    return if @department.users.blank?

    flash[:danger] = t "departments.errors.has_users"
    redirect_to admin_departments_path, status: :see_other
  end

  def filter_departments
    @departments = Department.search_by_name(params[:query])
                             .order_by_latest
    return if @departments.present?

    flash[:warning] = t "departments.index.table.no_result"
    redirect_to admin_departments_path, status: :see_other
  end
end
