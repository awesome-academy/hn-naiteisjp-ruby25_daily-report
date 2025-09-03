module Manager::DailyReportsHelper
  def manager_daily_report_action_buttons daily_report
    content_tag(:div, class: "btn-group") do
      link_to(
        edit_manager_daily_report_path(daily_report),
        class: "btn btn-sm btn-outline-primary",
        title: t("daily_reports.index.show")
      ) do
        content_tag(:i, "", class: "fas fa-eye")
      end
    end
  end

  def daily_report_filter_params
    params[:q]&.permit DailyReport::DEPARTMENT_FILTER_PARAMS
  end

  def manager_daily_report_status_options
    DailyReport.statuses.keys.map do |s|
      [t("daily_report.statuses.#{s}"), DailyReport.statuses[s]]
    end
  end
end
