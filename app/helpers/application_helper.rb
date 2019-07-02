# frozen_string_literal: true

module ApplicationHelper
  def env_class_name
    return 'development' if Rails.env.development?
    return 'staging' if Rails.env.staging?

    ''
  end

  def onboarding_flow?
    devise_controller?
  end

  def body_class_name
    class_names = []
    class_names.push('homepage') if homepage?
    class_names.push('onboarding-flow') if onboarding_flow?
    class_names.join(' ')
  end

  def homepage?
    current_page?(root_path)
  end

  def statistics?
    controller.is_a?(Reporting::InternshipOffersController) &&
      current_action?(:index)
  end

  def current_controller?(controller_name)
    controller.controller_name.to_s == controller_name.to_s
  end

  def current_action?(action_name)
    controller.action_name.to_s == action_name.to_s
  end
end
