class ProfilesController < ApplicationController
  before_action :check_user_role, :set_user

  def show; end

  def edit; end

  def update
    if @user.update profile_params
      flash[:success] = t "users.profile.profile_updated"
      redirect_to profile_path
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = current_user
  end

  def profile_params
    params.require(:user).permit User::PROFILE_PARAMS
  end
end
