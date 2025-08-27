module Manager::DepartmentsHelper
  def department_action_buttons department
    content_tag(:div, class: "btn-group") do
      link_to(
        manager_department_path(department),
        class: "btn btn-sm btn-outline-primary",
        title: t("departments.index.show")
      ) do
        content_tag(:i, "", class: "fas fa-eye")
      end
    end
  end

  def active_status_options selected_status
    options_for_select(
      [[t("users.index.all_status"), ""]] +
      Settings.active_status.map do |status|
        [I18n.t("users.index.filter.#{status}"), status]
      end,
      selected_status
    )
  end
end
