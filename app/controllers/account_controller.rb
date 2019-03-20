class AccountController < ApplicationController
  before_action :authenticate_user!

  def show
    authorize! :show, :account
  end

  def edit
    authorize! :edit, User
  end

  def update
    authorize! :update, User
    current_user.update!(user_params)
    redirect_to(account_path,
                flash: { success: 'Compte mis à jour avec succès' })
  rescue ActiveRecord::RecordInvalid => error
    render :edit, status: :bad_request
  end

  private
  def user_params
    params.require(:user).permit(:school_id, :first_name, :last_name,
      :resume_educational_background, :resume_volunteer_work, :resume_other)
  end
end
