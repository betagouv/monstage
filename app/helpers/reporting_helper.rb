module ReportingHelper
  def default_reporting_url_options(user)
    opts = {}
    return opts unless user
    opts[:department] = user.department_name if user.department_name.present?
    opts
  end

  def i18n_attribute(attribute_name)
    I18n.t(
      [
        'activerecord',
        'attributes',
        'internship_offer',
        attribute_name
      ].join('.')
    )
  end
end
