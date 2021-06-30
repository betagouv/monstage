# frozen_string_literal: true

module Users
  class SessionsController < Devise::SessionsController
    include Phonable
    before_action :configure_sign_in_params, only: %i[new create]
    after_action :remove_notice, only: %i[destroy create]
    after_action :switch_back, only: %i[destroy]

    def create
      user = fetch_user_by_phone
      super and return if user.nil?

      if by_phone? && !user.confirmed?
        user.send_sms_token
        redirect_to users_registrations_phone_standby_path(phone: safe_phone_param) and return
      end

      if by_phone? && user.valid_password?(params[:user][:password])
        sign_in(user)
        redirect_to after_sign_in_path_for(user) and return
      end

      super
    end

    protected

    # If you have extra params to permit, append them to the sanitizer.
    def configure_sign_in_params
      devise_parameter_sanitizer.permit(
        :sign_in,
        keys: %i[
          email
          phone
        ]
      )
    end

    private

    def remove_notice
      flash.delete(:notice)
    end

    def switch_back
      cookie_name = Rails.application.credentials.dig(:cookie_switch_back)
      switch_back = cookies.signed[cookie_name]

      return if switch_back.nil?

      user = User.find(switch_back)
      cookies.delete(cookie_name)
      sign_in(user, scope: :user)
    end
  end
end
