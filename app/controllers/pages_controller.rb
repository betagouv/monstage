# frozen_string_literal: true

class PagesController < ApplicationController
  layout 'homepage',
               only: :home

  def reset_cache
    Rails.cache.clear if can?(:reset_cache, current_user)
    redirect_to root_path
  end

  def register_to_webinar
    # if current_user.subscribed_to_webinar_at.nil?
      current_user.update(subscribed_to_webinar_at: Time.zone.now)
      redirect_to 'https://diagoriente.beta.gouv.fr',
                   allow_other_host: true,
                   notice: 'Vous voilà inscrit au webinar !'
    # else
    #   redirect_back fallback_location: root_path,
    #                 flash: { alert: 'Vous êtes déjà inscrit au webinar' }
    # end
  end
end
