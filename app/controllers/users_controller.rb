class UsersController < ApplicationController
  before_action :authenticate_user!

  def update
    authorize! :update, User

    user = User.find(params[:id])
    user.update!(user_params)

    redirect_to root_path, flash: { success: "Le compte de #{user.name} a bien été autorisé" }
  rescue ActiveRecord::RecordInvalid => error
    redirect_to root_path, status: :bad_request
  end

  private
  def user_params
    params.require(:user).permit(:has_parental_consent)
  end
end
