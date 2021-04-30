# frozen_string_literal: true

module Users
  class InvitedPasswordsController < Devise::PasswordsController
    def edit
      @minimum_password_length = User.password_length.min
      @user ||= User.fetch_user_by_reset_token(params[:reset_password_token])
      sign_in @user if role_invited?(@user)
      authorize! :invited_set_password, @user
      render 'devise/invited_passwords/edit'
    end

    def update
      authorize! :invited_set_password, current_user
      current_user.update!(password: params[:user][:password])
      bypass_sign_in(current_user)
      redirect_to dashboard_internship_offers_path
    rescue ActiveRecord::RecordInvalid
      @user = current_user
      render 'devise/invited_passwords/edit'
    end

    def role_invited?(user)
      return true if user.tutor?

      false
    end
  end
end
