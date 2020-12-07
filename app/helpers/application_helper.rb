# frozen_string_literal: true

module ApplicationHelper
  def show_restricted_to_anct?
    return false if Rails.env.test? # otherwise sticky position fucked up capybara
    return false if user_signed_in?
    return false if current_page?(internship_offers_path)
    return false if params[:id] && current_page?(internship_offer_path(id: params[:id]))

    true
  end

  def env_class_name
    return 'development' if Rails.env.development?
    return 'staging' if Rails.env.staging?

    ''
  end

  def helpdesk_url
    'https://monstage.zammad.com/help/fr-fr'
  end

  def custom_dashboard_controller?(user:)
    user.custom_dashboard_paths
        .map { |path| current_page?(path) }
        .any?
  end

  def account_controller?(user:)
    [
      current_page?(account_path),
      current_page?(account_path(section: :resume)),
      current_page?(account_path(section: :api)),
      current_page?(account_path(section: :identity)),
      current_page?(account_path(section: :school))
    ].any?
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
    controller.class.name.deconstantize == 'Reporting'
  end

  def current_controller?(controller_name)
    controller.controller_name.to_s == controller_name.to_s
  end

  def current_action?(action_name)
    controller.action_name.to_s == action_name.to_s
  end

  def page_title
    if content_for?(:page_title)
      content_for :page_title
    else
      default = 'Monstage'
      i18n_key = "#{controller_path.tr('/', '.')}.#{action_name}.page_title"
      dyn_page_name = t(i18n_key, default: default)

      "#{dyn_page_name} | #{default}" unless dyn_page_name == default
    end
  end
end
