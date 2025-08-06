module UserHelper
  def role_options_for_select
    options_for_select(
      Settings.FILTER_ROLE.map do |role|
        [I18n.t("users.roles.#{role}"), role.to_sym]
      end
    )
  end

  def department_options_for_select
    options_from_collection_for_select(
      Department.all,
      :id,
      :name,
      params[:department_id]
    )
  end

  def department_options_for_select_manager user
    options_from_collection_for_select(
      user.managed_departments || [],
      :id,
      :name,
      params[:department_id]
    )
  end

  def department_options_for_edit
    [[t("users.form.no_department"), nil]] +
      (@departments || []).map{|d| [d.name, d.id]}
  end
end
