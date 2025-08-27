module User::DailyReportsHelper
  def status_badge_class status
    case status.to_s
    when "read"
      "bg-info"
    when "pending"
      "bg-warning"
    else
      "bg-success"
    end
  end

  def daily_report_action_buttons daily_report
    content_tag(:div, class: "btn-group") do
      show_button = show_daily_report_button daily_report
      edit_button = edit_daily_report_button daily_report
      delete_button = delete_daily_report_button daily_report

      safe_join [show_button, edit_button, delete_button]
    end
  end

  private

  def show_daily_report_button daily_report
    link_to(
      user_daily_report_path(daily_report),
      class: "btn btn-sm btn-outline-primary",
      title: t("daily_report.index.show")
    ) do
      content_tag(:i, "", class: "fas fa-eye")
    end
  end

  def edit_daily_report_button daily_report
    return "" if daily_report.status_read? || daily_report.status_commented?

    link_to(
      edit_user_daily_report_path(daily_report),
      class: "btn btn-sm btn-outline-warning",
      title: t("daily_report.index.edit")
    ) do
      content_tag(:i, "", class: "fas fa-edit")
    end
  end

  def delete_daily_report_button daily_report
    return "" unless daily_report.status_pending?

    link_to(
      user_daily_report_path(daily_report),
      data: {
        "turbo-method": :delete,
        "turbo-confirm": t("daily_report.new.confirm_delete")
      },
      class: "btn btn-sm btn-outline-danger",
      title: t("daily_report.index.delete")
    ) do
      content_tag(:i, "", class: "fas fa-trash-alt")
    end
  end

  def daily_report_status_badge daily_report
    if daily_report.status_read?
      content_tag(:div, class: "alert alert-info") do
        "#{content_tag(:i, '', class: 'fas fa-check')} "\
          "#{t('daily_report.show.read')}"
      end
    elsif daily_report.status_commented?
      content_tag(:div, class: "alert alert-success") do
        "#{content_tag(:i, '', class: 'fas fa-pen')} "\
          "#{t('daily_report.show.commented')}"
      end
    else
      content_tag(:div, class: "alert alert-warning") do
        "#{content_tag(:i, '', class: 'fas fa-exclamation-triangle')} "\
          "#{t('daily_report.show.pending')}"
      end
    end
  end

  def daily_reports_calendar_show daily_reports
    month_calendar(events: daily_reports,
                   attribute: :report_date) do |date, reports|
      content_tag(:div, class: "day") do
        report = reports.first

        if report.present?
          status_class =
            case report.status.to_sym
            when :read      then "bg-info text-white"
            when :commented then "bg-success text-white"
            when :pending   then "bg-warning text-dark"
            else "bg-light"
            end

          link_to(
            report.report_date.day,
            user_daily_report_path(report),
            class: "btn #{status_class} w-100 mb-2"
          )
        else
          content_tag(:span, date.day, class: "text-muted")
        end
      end
    end
  end

  def daily_report_status_options selected = params.dig(:q, :status_eq)
    options_for_select(
      DailyReport.statuses.map{|key, value| [key.titleize, value]},
      selected
    )
  end
end
