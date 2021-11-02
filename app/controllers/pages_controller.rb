# frozen_string_literal: true

class PagesController < ApplicationController
  layout 'homepage', only: :home

  def reset_cache
    Rails.cache.clear if can?(:reset_cache, current_user)
    redirect_to root_path
  end
end
