class AccountsController < ApplicationController
  before_action :find_selectable_weeks, only: [:edit, :update]
  before_action :authenticate_user!

  def update
    current_user.update(user_params)

    if current_user.instance_of? SchoolManager
      params[:internship_weeks].each do |week_id|
        SchoolInternshipWeek.create(school_id: current_user.school.id, week_id: week_id)
      end
    end

    flash[:success] = 'Compte mis à jour avec succès'
    render 'accounts/edit'
  end

  private
  def user_params
    params.require(:user).permit(:school_id)
  end
end
