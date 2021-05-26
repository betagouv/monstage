# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :authenticate_user!

  def edit
    authorize! :update, current_user
    redirect_to = account_path(section: :school)
    if force_select_school? && can_redirect?(redirect_to)
      redirect_to(redirect_to,
                  flash: { danger: "Veuillez rejoindre un etablissement" })
      return
    end
  end

  def update
    authorize! :update, current_user
    current_user.update!(user_params)
    redirect_back fallback_location: account_path, flash: { success: current_flash_message }
  rescue ActiveRecord::RecordInvalid
    render :edit, status: :bad_request
  end

  def update_password 
    authorize! :update, current_user
    if password_change_allowed?
      current_user.update!(user_params)
      sign_in :user, current_user, bypass: true
      redirect_to  account_path(section: :password), flash: { success: current_flash_message }
    else
      redirect_to account_path(section: :password), flash: { warning: 'impossible de mettre à jour le mot de passe.' }
    end
  rescue ActiveRecord::RecordInvalid
    render :edit, status: :bad_request
  end

  helper_method :current_section

  private

  def current_flash_message
    message = if params.dig(:user, :missing_weeks_school_id).present?
              then "Nous allons prévenir votre chef d'établissement pour que vous puissiez postuler"
              else 'Compte mis à jour avec succès.'
              end
    message += " Un courriel a été envoyé à l'ancienne adresse électronique (e-mail). Veuillez cliquer sur le lien contenu dans le courriel pour confirmer votre nouvelle adresse électronique (e-mail)." if current_user.unconfirmed_email
    message
  end

  def user_params
    params.require(:user).permit(:school_id,
                                 :missing_weeks_school_id,
                                 :first_name,
                                 :last_name,
                                 :email,
                                 :phone,
                                 :department,
                                 :class_room_id,
                                 :resume_educational_background,
                                 :resume_other,
                                 :resume_languages,
                                 :password,
                                 :password_confirmation,
                                 :role)
  end

  def current_section
    params[:section] || current_user.default_account_section
  end

  def force_select_school?
    current_user.missing_school? && current_section.to_s != "school"
  end

  def can_redirect?(path)
    request.path != path
  end

  def password_change_allowed?
    current_user.valid_password?(params[:user][:current_password])
  end
end
