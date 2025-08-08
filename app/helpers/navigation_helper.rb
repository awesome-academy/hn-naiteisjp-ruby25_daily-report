module NavigationHelper
  def nav_items_for role
    all_items = nav_items
    filter_items_by_role all_items, role
  end

  private

  def nav_items
    [
      {
        label: t("nav_items.dashboard"),
        path: root_path,
        icon: "tachometer-alt",
        roles: %w(admin manager user)
      },
      {
        label: t("nav_items.departments"),
        path: admin_departments_path,
        icon: "home",
        roles: %w(admin)
      },
      {
        label: t("nav_items.departments"),
        path: manager_departments_path,
        icon: "home",
        roles: %w(manager)
      },
      {
        label: t("nav_items.users"),
        path: admin_users_path,
        icon: "users",
        roles: %w(admin)
      },
      {
        label: t("nav_items.users"),
        path: manager_users_path,
        icon: "users",
        roles: %w(manager)
      },
      {
        label: t("nav_items.reports"),
        path: manager_daily_reports_path,
        icon: "file",
        roles: %w(manager)
      },
      {
        label: t("nav_items.reports"),
        path: user_daily_reports_path,
        icon: "file",
        roles: %w(user)
      },
      {
        label: t("nav_items.help"),
        path: help_path,
        icon: "handshake-angle",
        roles: %w(admin manager user)
      },
      {
        label: t("nav_items.logout"),
        path: nil,
        icon: "sign-out",
        roles: %w(admin manager user)
      }
    ]
  end

  def filter_items_by_role items, role
    items.select{|item| item[:roles].include?(role.to_s)}
  end
end
