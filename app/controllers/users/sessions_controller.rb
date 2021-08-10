# frozen_string_literal: true

module Users
  class SessionsController < Devise::SessionsController
    include Phonable
    before_action :configure_sign_in_params, only: %i[new create]
    after_action :remove_notice, only: %i[destroy create]
    after_action :switch_back, only: %i[destroy]

    def create
      user_with_email = fetch_user_by_email
      user_with_phone = fetch_user_by_phone
      user = user_with_phone || user_with_email
      store_targeted_offer_id(user: user)

      if user_with_email.nil? && !user_with_phone&.confirmed?
        user_with_phone.send_sms_token
        redirect_to users_registrations_phone_standby_path(phone: safe_phone_param) and return
      end

      if user&.valid_password?(params[:user][:password])
        sign_in(user)
        redirect_to after_sign_in_path_for(user) and return
      end

      super
    end

    protected

    def store_targeted_offer_id(user:)
      if user && params[:user][:targeted_offer_id].present?
        user.update(targeted_offer_id: params[:user][:targeted_offer_id])
      end
    end

    def fetch_user_by_email
      param_email = params[:user][:email]
      return User.find_by(email: params[:user][:email]) if param_email.present?
    end

    # If you have extra params to permit, append them to the sanitizer.
    def configure_sign_in_params
      devise_parameter_sanitizer.permit(
        :sign_in,
        keys: %i[
          email
          phone
          targeted_offer_id
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
