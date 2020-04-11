# frozen_string_literal: true

module Users
  class SessionsController < Devise::SessionsController
    after_action :remove_notice, only: %i[destroy create]
    after_action :switch_back, only: %i[destroy]

    private

    def remove_notice
      flash.delete(:notice)
    end

    def switch_back
      cookie_name = Credentials.enc(:cookie_switch_back, prefix_env: false)
      switch_back = cookies.signed[cookie_name]

      return if switch_back.nil?

      user = User.find(switch_back)
      cookies.delete(cookie_name)
      sign_in(user, scope: :user)
    end
  end
end
