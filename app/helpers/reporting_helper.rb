# frozen_string_literal: true

module ReportingHelper
  def default_reporting_url_options(user, extra={})
    opts = {}
    return opts unless user

    opts[:department] = user.department if user.department.present?
    opts[:school_year] = params[:school_year] || SchoolYear::Current.new.beginning_of_period.year
    opts[:subscribed_school] = opts[:subscribed_school] || false
    opts.merge!(extra) unless extra.blank?
    opts
  end

  def stats_breadcrumb_links(params:, user:)
    if params[:department].present? && params[:group].present?
      [ [reporting_internship_offers_path(default_reporting_url_options(user)),  'Statistiques'],
              [reporting_internship_offers_path(department: params[:department]), params[:department]],
              ['', params[:group]] ]
    elsif params[:department].present?
      [ [reporting_internship_offers_path(default_reporting_url_options(user)),  'Statistiques'],
              ['', params[:department]] ]
    elsif params[:group].present?
      [ [reporting_internship_offers_path(default_reporting_url_options(user)),  'Statistiques'],
              ['', params[:group]] ]
    else
      [ ['',  'Statistiques nationales'] ]
    end
  end
end
