# frozen_string_literal: true

class PagesController < ApplicationController
  WEBINAR_URL = 'https://app.livestorm.co/incubateur-des-territoires/permanence-monstagedetroisiemefr?type=detailed'
  layout 'homepage', only: :home

  def reset_cache
    Rails.cache.clear if can?(:reset_cache, current_user)
    redirect_to root_path
  end

  def register_to_webinar
    reset_old_participation
    if current_user.subscribed_to_webinar_at.nil?
      current_user.update(subscribed_to_webinar_at: Time.zone.now)
      redirect_to WEBINAR_URL,
                  allow_other_host: true,
                  notice: 'Vous voilà inscrit au webinar !'
    else
      redirect_back fallback_location: root_path,
                    flash: { alert: 'Vous êtes déjà inscrit au webinar' }
    end
  end

  def reset_old_participation
    return if current_user.subscribed_to_webinar_at.nil?

    if current_user.subscribed_to_webinar_at <= previous_friday
      current_user.update(subscribed_to_webinar_at: nil)
    end
  end

  def previous_friday
    today = Time.zone.today
    today - today.wday - 2
  end
end
