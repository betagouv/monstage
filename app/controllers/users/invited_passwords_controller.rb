# frozen_string_literal: true

module Users
  class InvitedPasswordsController < Devise::PasswordsController
    # See : https://github.com/thoughtbot/clearance/issues/621
    skip_before_action :authenticate_user!, raise: false, only: %i[edit update]

    def edit
      @minimum_password_length = User.password_length.min
      @user ||= User.with_reset_password_token(params[:reset_password_token])
      render 'devise/invited_passwords/edit'
    end

    def update
      @user ||= User.find_by_reset_password_token!(invited_params[:reset_password_token])
      @user.update!(password: invited_params[:password])
      sign_in(@user)
      redirect_to dashboard_internship_offers_path, flash: { success: 'Votre compte a bien été créé.' }
    rescue ActiveRecord::RecordNotFound
      flash[:error] = 'Le formulaire soumis contient des erreurs'
      render 'devise/invited_passwords/edit'
    rescue ActiveRecord::RecordInvalid
      flash[:error] = 'Le lien utilisé n\'est pas valide'
      render 'devise/invited_passwords/edit'
    end

    private

    def invited_params
      params.require(:user)
            .permit(:reset_password_token,
                    :password,
                    :password_confirmation)
    end
  end
end
