# frozen_string_literal: true

module Users
  class SessionsController < Devise::SessionsController
    before_action :configure_sign_in_params, only: [:new]
    after_action :remove_notice, only: %i[destroy create]
    after_action :switch_back, only: %i[destroy]

    def create
      params[:user][:phone] = params[:user][:phone].delete(' ')
      if params[:user][:phone].present?
        user = User.where(phone: params[:user][:phone]).first
        if user && user.valid_password?(params[:user][:password])
          sign_in(user)
          redirect_to root_path
        else
          super
        end
      else
        super
      end
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
      cookie_name = Credentials.enc(:cookie_switch_back, prefix_env: false)
      switch_back = cookies.signed[cookie_name]

      return if switch_back.nil?

      user = User.find(switch_back)
      cookies.delete(cookie_name)
      sign_in(user, scope: :user)
    end
  end
end
