module Schools
  class UsersController < ApplicationController
    before_action :authenticate_user!, only: [:destroy]
    before_action :set_school

    def destroy
      user = @school.users.find(params[:id])
      user_presenter = Presenters::User.new(user: user)
      authorize! :delete, user
      user.update!(school_id: nil)
      redirect_to account_path,
                  flash: { success: "Le #{user_presenter.role_name} #{user_presenter.short_name} a bien été supprimé de votre collège"}
    rescue ActiveRecord::RecordInvalid => error
      redirect_to account_path,
                  flash: { success: "Une erreur est survenue, impossible de supprimé #{user_presenter.human_role} #{user_presenter.short_name} de votre collège: #{error.record.full_messages}"}
    end

    private
    def set_school
      @school = School.find(params.require(:school_id))
    end
  end
end
