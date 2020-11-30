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

  helper_method :current_section

  private

  def current_flash_message
    message = if params.dig(:user, :missing_school_weeks_id).present?
              then "Nous allons prévenir votre chef d'établissement pour que vous puissiez postuler"
              else 'Compte mis à jour avec succès.'
              end
    message += "Un email a été envoyé à l'ancienne adresse. Veuillez cliquer sur le lien contenu dans l'email pour confirmer votre nouvelle Adresse électronique (e-mail)." if current_user.unconfirmed_email
    message
  end

  def user_params
    params.require(:user).permit(:school_id,
                                 :missing_school_weeks_id,
                                 :first_name,
                                 :last_name,
                                 :email,
                                 :phone,
                                 :department_name,
                                 :class_room_id,
                                 :resume_educational_background,
                                 :resume_other,
                                 :resume_languages,
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
end
