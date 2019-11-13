# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :authenticate_user!

  def edits
    authorize! :update, current_user
  end

  def update
    authorize! :update, current_user
    current_user.update!(user_params)
    flash_message = 'Compte mis à jour avec succès.'
    flash_message += ' Veuillez confirmer votre nouvelle adresse email.' if current_user.unconfirmed_email
    redirect_back fallback_location: account_path, flash: { success: flash_message }
  rescue ActiveRecord::RecordInvalid
    render :edit, status: :bad_request
  end

  helper_method :current_section
  private

  def user_params
    params.require(:user).permit(:school_id,
                                 :first_name,
                                 :last_name,
                                 :email,
                                 :phone,
                                 :department_name,
                                 :class_room_id,
                                 :resume_educational_background,
                                 :resume_other,
                                 :resume_languages)
  end

  def current_section
    params[:section] || current_user.default_account_section
  end
end
