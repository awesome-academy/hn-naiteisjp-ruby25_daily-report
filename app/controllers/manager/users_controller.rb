class Manager::UsersController < ApplicationController
  load_and_authorize_resource class: User.name, except: :create
  before_action :manager_user
  before_action :get_unassigned_users, only: %i(new create)

  def new; end

  def create
    authorize! :create, User
    user = @available_users.find_by id: params[:user_id]
    department = current_user.department
    if user && department
      user.update(department:)
      flash[:success] = t "users.assign.success"
      redirect_to manager_department_path(current_user.department)
    else
      flash[:danger] = t "users.assign.fail"
      redirect_to new_manager_user_path
    end
  end

  def show; end

  def destroy
    if @user.update department_id: nil
      flash[:success] = t "users.success.deleted"
    else
      flash[:danger] = t "users.error.delete_failed"
    end
    redirect_to manager_department_path(current_user.department)
  end

  private

  def user_params
    params.require(:user).permit User::USER_PARAMS
  end

  def get_unassigned_users
    @available_users = User.unassigned_users
    return if @available_users.present?

    flash[:warning] = t "users.new.no_user_for_assign"
    redirect_to manager_department_path(current_user.department)
  end
end
