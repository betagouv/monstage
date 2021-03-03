# frozen_string_literal: true

module ReportingHelper
  def default_reporting_url_options(user)
    opts = {}
    return opts unless user

    opts[:department] = user.department_name if user.department_name.present?
    opts[:school_year] =  params.key?(:school_year) ? params[:school_year] : SchoolYear::Current.new.beginning_of_period.year
    opts
  end
end
