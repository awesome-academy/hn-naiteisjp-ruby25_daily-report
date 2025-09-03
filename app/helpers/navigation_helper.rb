module NavigationHelper
  def nav_items_for role
    all_items = nav_items
    filter_items_by_role all_items, role
  end

  private

  def nav_items
    raw_nav_item_data.compact.map do |item|
      build_nav_item(item[:label], item[:path], item[:icon], item[:roles])
    end
  end

  def filter_items_by_role items, role
    items.select{|item| item[:roles].include?(role.to_s)}
  end

  def build_nav_item label, path, icon, roles
    {
      label: t("nav_items.#{label}"),
      path:,
      icon:,
      roles:
    }
  end

  def raw_nav_item_data
    [
      {
        label: "dashboard",
        path: admin_dashboard_show_path,
        icon: "tachometer-alt",
        roles: %w(admin)
      },
      {
        label: "dashboard",
        path: user_dashboard_show_path,
        icon: "tachometer-alt",
        roles: %w(user)
      },
      {
        label: "dashboard",
        path: manager_dashboard_show_path,
        icon: "tachometer-alt",
        roles: %w(manager)
      },
      {
        label: "reports",
        path: manager_daily_reports_path,
        icon: "file",
        roles: %w(manager)
      },
      {
        label: "departments",
        path: admin_departments_path,
        icon: "home",
        roles: %w(admin)
      },
      if current_user.department.present?
        {
          label: "my_department",
          path: manager_department_path(current_user.department),
          icon: "home",
          roles: %w(manager)
        }
      end,
      {
        label: "users",
        path: admin_users_path,
        icon: "users",
        roles: %w(admin)
      },
      {
        label: "reports",
        path: user_daily_reports_path,
        icon: "file",
        roles: %w(user)
      },
      {
        label: "profile",
        path: profile_path,
        icon: "user",
        roles: %w(user)
      },
      {
        label: "logout",
        path: nil,
        icon: "sign-out",
        roles: %w(admin manager user)
      }
    ]
  end
end
