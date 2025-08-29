module Admin::DepartmentsHelper
  def admin_department_action_buttons department
    content_tag(:div, class: "btn-group") do
      safe_join([
        department_show_button(department),
        department_edit_button(department),
        department_delete_button(department)
      ].compact)
    end
  end

  def department_status_options selected = params[:status]
    options_for_select(status_options, selected)
  end

  private

  def department_show_button department
    link_to(
      admin_department_path(department),
      class: "btn btn-sm btn-outline-primary",
      title: t("departments.index.show")
    ) do
      content_tag(:i, "", class: "fas fa-eye")
    end
  end

  def department_edit_button department
    link_to(
      edit_admin_department_path(department),
      class: "btn btn-sm btn-outline-warning",
      title: t("departments.index.edit")
    ) do
      content_tag(:i, "", class: "fas fa-edit")
    end
  end

  def department_delete_button department
    return if department.deleted?

    link_to(
      admin_department_path(department),
      data: {
        "turbo-method": :delete,
        "turbo-confirm": t("departments.index.confirm_delete")
      },
      class: "btn btn-sm btn-outline-danger",
      title: t("departments.index.delete")
    ) do
      content_tag(:i, "", class: "fas fa-trash-alt")
    end
  end

  def status_options
    Settings.active_status.map do |status|
      [I18n.t("departments.index.table.#{status}"), status]
    end
  end
end
