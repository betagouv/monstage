class UrlShrinkersController < ApplicationController
  rescue_from "ActiveRecord::RecordNotFound" , with: :unknown_token_handler

  def open
    url_shrinker = UrlShrinker.fetch(url_token: params[:url_token])
    if url_shrinker
      # TODO user = User.find(url_shrinker.user_id)
      # sign_in(user, scope: :user)
      url_shrinker.increment_clicks!
      redirect_to url_shrinker.original_url
    else
      render json: { error: 'Url not found' }, status: 404
    end
  end

  private

  def unknown_token_handler(exception)
    redirect_to root_url, alert: exception.message
  end
end