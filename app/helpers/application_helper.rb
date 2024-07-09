# frozen_string_literal: true

module ApplicationHelper
  def env_class_name
    return 'development' if Rails.env.development?
    return 'staging' if Rails.env.staging?

    ''
  end

  def helpdesk_url
    'https://zammad.mon-stage-de-troisieme.incubateur.anct.gouv.fr/help/fr-fr'
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
    devise_controller? && request.path.include?('identity_id')
  end

  def body_class_name
    class_names = []
    class_names.push('homepage px-0') if homepage?
    class_names.push('onboarding-flow') if onboarding_flow?
    class_names.join(' ')
  end

  def homepage?
    current_page?(root_path)
  end

  def in_dashboard?
    request.path.include?('dashboard') || request.path.include?('tableau-de-bord')
  end

  def statistics?
    controller.class.name.deconstantize == 'Reporting'
  end

  def current_controller?(controller_name)
    controller.controller_name.to_s == controller_name.to_s
  end


  def page_title
    if content_for?(:page_title)
      content_for :page_title
    else
      default = 'Monstage'
      i18n_key = "#{controller_path.tr('/', '.')}.#{action_name}.page_title"
      dyn_page_name = t(i18n_key, default: default)
      dyn_page_name == default ? default : "#{dyn_page_name} | #{default}"
    end
  end
end
