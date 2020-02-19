# frozen_string_literal: true

module ReportingHelper
  def default_reporting_url_options(user)
    opts = {}
    return opts unless user

    opts[:department] = user.department_name if user.department_name.present?
    opts
  end
end
