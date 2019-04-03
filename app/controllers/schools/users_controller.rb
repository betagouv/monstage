module Schools
  class UsersController < ApplicationController
    include NestedSchool

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

    def update
      user = @school.users.find(params[:id])

      authorize! :update, user
      user.update!(user_params)

      redirect_to request.referer, flash: { success: "Le compte de #{user.name} a bien été autorisé" }
    rescue ActiveRecord::RecordInvalid => error
      redirect_to request.referer, status: :bad_request
    end

    private
    def user_params
      params.require(:user).permit(:has_parental_consent)
    end
  end
end
