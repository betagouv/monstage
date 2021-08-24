# frozen_string_literal: true

class PagesController < ApplicationController
  def reset_cache
    Rails.cache.clear if can?(:reset_cache, current_user)
    redirect_to root_path
  end

  def blog
  end

  def blog_post
    @blog_post = PrismicFinder.blog_post(params[:slug])
  end
end
