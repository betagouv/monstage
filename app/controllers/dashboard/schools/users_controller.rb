# frozen_string_literal: true

module Dashboard
  module Schools
    class UsersController < ApplicationController
      include NestedSchool

      def index
        authorize! :manage_school_users, @school
        @collection = @school.main_teachers.kept + @school.teachers.kept + @school.others.kept
      end

      def destroy
        user = @school.users.find(params[:id])
        user_presenter = Presenters::User.new(user)
        authorize! :delete, user
        user.update!(school_id: nil, class_room_id: nil)

        redirect_to dashboard_school_users_path(@school),
                    flash: { success: "Le #{user_presenter.role_name} #{user_presenter.short_name} a bien été retiré de votre établissement" }
      rescue ActiveRecord::RecordInvalid
        redirect_to dashboard_school_users_path(@school),
                    flash: { success: "Une erreur est survenue, impossible de supprimé #{user_presenter.human_role} #{user_presenter.short_name} de votre établissement: #{e.record.full_messages}" }
      end

      def update
        user = @school.users.find(params[:id])

        authorize! :update, user
        user.update!(user_params)
        redirect_back fallback_location: root_path
      rescue ActiveRecord::RecordInvalid
        redirect_back fallback_location: root_path, status: :bad_request
      end

      private

      def user_params
        params.require(:user).permit(:custom_track)
      end
    end
  end
end
