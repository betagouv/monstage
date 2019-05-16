module ApplicationHelper
  def env_class_name
    return "development" if Rails.env.development?
    return "staging" if Rails.env.staging?
    ""
  end

  def current_controller?(controller_name)
    controller.controller_name.to_s == controller_name.to_s
  end
end
