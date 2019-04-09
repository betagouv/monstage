module Dashboard
  module Schools
    class ClassRoomsController < ApplicationController
      include NestedSchool

      def create
        authorize! :create, ClassRoom
        @school = current_user.school
        @class_room = @school.class_rooms.new(class_rooms_params)
        @class_room.save!
        redirect_to account_path,
                    flash: { success: "Classe ajoutée avec succès" }
      rescue ActiveRecord::RecordInvalid => error
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
        redirect_to account_path,
                   flash: { success: "Classe mise à jour avec succès" }
      rescue ActiveRecord::RecordInvalid => error
        render :edit
      end

      def new
        authorize! :new, ClassRoom
        @school = current_user.school
        @class_room = @school.class_rooms.new
      end

      private
      def class_rooms_params
        params.require(:class_room).permit(:name)
      end
    end
  end
end
