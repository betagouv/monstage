# frozen_string_literal: true

module Dashboard
  module Schools
    class ClassRoomsController < ApplicationController
      include NestedSchool

      def index
        authorize! :index, ClassRoom
        set_empty_weeks_modal_visibility
      end

      def show
        authorize! :show, ClassRoom
        @class_room = @school.class_rooms.find(params[:id])
      end

      def create
        authorize! :create, ClassRoom
        @school = current_user.school
        @class_room = @school.class_rooms.new(class_rooms_params)
        @class_room.save!
        redirect_to dashboard_school_path(@school),
                    flash: { success: 'Classe ajoutée avec succès' }
      rescue ActiveRecord::RecordInvalid
        render :new
      end

      def edit
        authorize! :edit, ClassRoom
        @school = current_user.school
        @class_room = @school.class_rooms.find(params[:id])
      end

      def update
        authorize! :update, ClassRoom
        @school = current_user.school
        @class_room = @school.class_rooms.find(params[:id])
        @class_room.update!(class_rooms_params)
        redirect_to dashboard_school_class_rooms_path(@school),
                    flash: { success: 'Classe mise à jour avec succès' }
      rescue ActiveRecord::RecordInvalid
        render :edit
      end

      def new
        authorize! :new, ClassRoom
        @school = current_user.school
        @class_room = @school.class_rooms.new
      end

      def destroy
        authorize! :destroy, ClassRoom
        @school = current_user.school
        @class_room = @school.class_rooms.find(params[:id])
        @class_room.destroy!
        redirect_to dashboard_school_class_rooms_path(@school),
                    flash: { success: 'Classe supprimée avec succès' }
      rescue ActiveRecord::RecordInvalid
        render :edit
      end

      private

      def class_rooms_params
        params.require(:class_room)
              .permit(:name)
      end

      def set_empty_weeks_modal_visibility
        @modal_visibility = false
        return if @school.has_weeks_on_current_year?

        if user_session['empty_weeks_modal_shown'].blank?
          user_session['empty_weeks_modal_shown'] = true
          @modal_visibility = true
        end
      end
    end
  end
end
