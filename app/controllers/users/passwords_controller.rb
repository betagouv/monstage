# frozen_string_literal: true

module Users
  class PasswordsController < Devise::PasswordsController
    include Phonable
    def create
      if by_phone? && fetch_user_by_phone.nil?
        redirect_to(
          new_user_password_path,
          flash: { alert: I18n.t('errors.messages.unknown_phone_number') }
        )
        return
      elsif by_phone? && fetch_user_by_phone
        fetch_user_by_phone.reset_password_by_phone
        redirect_to phone_edit_password_path(phone: safe_phone_param)
        return
      end
      
      super
    end

    def edit
      @current_user = User.with_reset_password_token(params['reset_password_token'])
      @teacher = User.find(params['teacher_id']) if params['teacher_id'].present?
      super
    end

    def update
      current_user = User.with_reset_password_token(params['user']['reset_password_token'])
      if current_user && current_user.created_by_teacher
        current_user.password = params['user']['password']
        current_user.save
        current_user.confirm if current_user.confirmed_at.nil?
        redirect_to new_user_session_path, flash: { success:  'Mot de passe enregistré !' }
      else
        super
      end
    end

    def edit_by_phone; end


    def set_up
    end 

    def update_by_phone
      if fetch_user_by_phone.try(:check_phone_token?, params[:phone_token])
        @user.update(password: params[:password])
        sign_in @user
        @user.confirm_by_phone!
        redirect_to @user.after_sign_in_path, flash: { success: I18n.t('devise.passwords.updated') }
      else
        redirect_to(phone_edit_password_path(phone: safe_phone_param),
                    flash: { alert: 'Le téléphone mobile ou le code est invalide.' })
      end
    end
  end
end
