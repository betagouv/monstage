class UrlShrinkersController < ApplicationController
  rescue_from "ActiveRecord::RecordNotFound" , with: :unknown_token_handler

  def open
    url_shrinker = UrlShrinker.fetch(url_token: params[:id])
    if url_shrinker
      url_shrinker.increment_clicks!
      redirect_to url_shrinker.original_url, allow_other_host: true
    else
      redirect_to root_url, alert: "Le lien est périmé"
    end
  end

  private

  def unknown_token_handler(exception)
    redirect_to root_url, alert: exception.message
  end
end
