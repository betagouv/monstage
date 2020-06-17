# frozen_string_literal: true

module Users
  class PasswordsController < Devise::PasswordsController

    def create
      if params[:user][:phone].present?
        phone = params[:user][:phone].delete(' ')
        user = User.where(phone: phone).first
        if user
          user.send_confirmation_sms
          redirect_to phone_edit_password_path(phone: phone)
        else
           super
        end
      else
        super
      end
    end

    def edit_by_phone
    end

    def update_by_phone
      phone = params[:phone].delete(' ')
      user = User.where(phone: phone).first
      if user.try(:phone_confirmable?) && user.phone_token == params[:phone_token]
        user.update(phone_token: nil, phone_token_validity: nil, confirmed_at: Time.now)
        redirect_to root_path, flash: { success: I18n.t('devise.passwords.updated') }
      else
        redirect_to phone_edit_password_path(phone: params[:phone]), alert: "Le téléphone mobile ou le code est invalide."
      end
    end
  end
end
