# frozen_string_literal: true

class PagesController < ApplicationController
  WEBINAR_URL = ENV.fetch('WEBINAR_URL').freeze
  layout 'homepage', only: :home

  def reset_cache
    Rails.cache.clear if can?(:reset_cache, current_user)
    redirect_to root_path
  end

  def register_to_webinar
    authorize! :subscribe_to_webinar, current_user
    # Remove comments after #31/12/2022

    # reset_old_participation
    # if current_user.subscribed_to_webinar_at.nil?
    current_user.update(subscribed_to_webinar_at: Time.zone.now)
    redirect_to WEBINAR_URL,
                allow_other_host: true
    # else
    #   alert_text = "Vous êtes déjà inscrit au prochain webinar Monstage"
    #   redirect_back fallback_location: root_path,
    #                 flash: { alert: alert_text }
    # end
  end

  # Remove comments after #31/12/2022
  # def reset_old_participation
  #   return if current_user.subscribed_to_webinar_at.nil?

  #   if current_user.subscribed_to_webinar_at <= previous_friday
  #     current_user.update(subscribed_to_webinar_at: nil)
  #   end
  # end

  # def previous_friday
  #   today = Time.zone.today
  #   today - today.wday - 2
  # end

  def flyer
    respond_to do |format|
      format.html
      format.pdf do
        send_data(
          File.read(Rails.root.join("public", "MS3_Flyer_2022.pdf")),
          filename: "MS3E_flyer_2022.pdf",
          type: 'application/pdf',
          disposition: 'inline'
        )
      end
    end
  end
end
