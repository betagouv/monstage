# frozen_string_literal: true

module Users
  class PasswordsController < Devise::PasswordsController
    include Phonable
    def create
      if by_phone? && fetch_user_by_phone
        fetch_user_by_phone.send_confirmation_sms
        redirect_to phone_edit_password_path(phone: safe_phone_param)
      end
      super
    end

    def edit_by_phone
    end

    def update_by_phone
      if fetch_user_by_phone.try(:check_phone_token?, params[:phone_token])
        fetch_user_by_phone.confirm_by_phone!
        redirect_to root_path, flash: { success: I18n.t('devise.passwords.updated') }
      else
        redirect_to(phone_edit_password_path(phone: safe_phone_param),
                    flash: { alert: "Le téléphone mobile ou le code est invalide." })
      end
    end
  end
end
