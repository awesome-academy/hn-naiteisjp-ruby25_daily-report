class RegistrationsController < Devise::RegistrationsController
  protected

  def after_update_path_for _resources
    profile_path
  end
end
