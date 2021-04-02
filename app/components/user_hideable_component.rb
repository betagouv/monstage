# frozen_string_literal: true

class UserHideableComponent < ApplicationComponent
  def has_been_shown?
    user.banners.fetch(partial_path) { false }
  end

  def partial_locals
    { user: user }
  end

  private
  attr_reader :user, :partial_path

  def initialize(user:, partial_path:)
    @user = user
    @partial_path = partial_path
  end
end
