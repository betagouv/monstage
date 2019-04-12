class ResumesController < ApplicationController
  before_action :authenticate_user!

  def edit
    authorize! :update, current_user
  end

  def update
    authorize! :update, current_user
    current_user.update!(user_params)
    redirect_to resume_path, flash: { success: 'Compte mis à jour avec succès' }
  rescue ActiveRecord::RecordInvalid => error
    render :edit, status: :bad_request
  end

  private
  def user_params
    params.require(:user).permit(:resume_educational_background,
                                 :resume_volunteer_work,
                                 :resume_other,
                                 :resume_languages)
  end
end
