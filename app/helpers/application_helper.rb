module ApplicationHelper
  def env_class_name
    return "development" if Rails.env.development?
    return "staging" if Rails.env.staging?
    ""
  end
end
