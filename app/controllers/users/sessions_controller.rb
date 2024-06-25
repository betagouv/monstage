# frozen_string_literal: true

module Users
  class SessionsController < Devise::SessionsController
    include Phonable
    before_action :configure_sign_in_params, only: %i[new create]
    after_action :remove_notice, only: %i[destroy create]
    after_action :switch_back, only: %i[destroy]

    def new
      params[:as] = session[:as] if session[:as].present?
      super and return if confirmed? ||
                          params[:check_confirmation].nil?

      redirect_to_path = users_registrations_standby_path(
        check_confirmation: true,
        id: params[:id]
      )
      flash_message = 'Vous trouverez parmi vos emails le message' \
                      ' permettant l\'activation de votre compte'
      redirect_to(redirect_to_path, flash: { warning: flash_message }) and return
    end

    def create
      if by_phone? && fetch_user_by_phone.try(:valid_password?, params[:user][:password])
        user = fetch_user_by_phone
        if user.student?
          store_targeted_offer_id(user: user)
          if user.confirmed?
            sign_in(user)
            redirect_to after_sign_in_path_for(user)
          else
            user.send_sms_token
            redirect_to users_registrations_phone_standby_path(phone: safe_phone_param)
          end
          return
        end
      end
      store_targeted_offer_id(user: fetch_user_by_email)
      super
    end

    def destroy
      super do
        cookies.delete(:_monstage_session)
        cookies.delete(:_ms2gt_manage_session)
      end
    end

    protected

    def store_targeted_offer_id(user:)
      if params[:user].nil?
        Rails.logger.error("--------------\n#{params}\n--------------\n")
        raise 'params[:user] is nil'
      end
      if user && params[:user][:targeted_offer_id].present?
        user.update(targeted_offer_id: params[:user][:targeted_offer_id])
      end
    end

    def fetch_user_by_email
      if params[:user].nil?
        Rails.logger.error("--------------\n#{params}\n--------------\n")
        raise 'params[:user] is nil'
      end
      param_email = params[:user][:email]
      return User.find_by(email: param_email) if param_email.present?
    end

    # If you have extra params to permit, append them to the sanitizer.
    def configure_sign_in_params
      devise_parameter_sanitizer.permit(
        :sign_in,
        keys: %i[
          check_confirmation
          email
          id
          phone
          targeted_offer_id
        ]
      )
    end

    private

    def remove_notice
      flash.delete(:notice)
    end

    def confirmed?
      return false if params[:check_confirmation].nil? || params[:id].nil?

      identify_user_with_id
      @user && @user.confirmed_at.present?
    end

    def switch_back
      cookie_name = Rails.application.credentials.dig(:cookie_switch_back)
      switch_back = cookies.signed[cookie_name]

      return if switch_back.nil?

      user = User.find(switch_back)
      cookies.delete(cookie_name)
      sign_in(user, scope: :user)
    end

    def identify_user_with_id
      @user = User.find_by(id: params[:id])
    end
  end
end
