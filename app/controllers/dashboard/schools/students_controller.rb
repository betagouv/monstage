# frozen_string_literal: true

module Dashboard
  module Schools
    class StudentsController < ApplicationController
      include NestedSchool

      def index
        authorize! :manage_school_students, @school
        navbar_badges
      end

      def update
        authorize! :manage_school_students, @school
        student = @school.students.find(params[:id])
        student.update!(students_params)
        redirect_back fallback_location: dashboard_school_users_path(@school),
                      flash: { success: "#{student.name} a été mis à jour" }
      rescue ActiveRecord::RecordInvalid
        redirect_back fallback_location: dashboard_school_users_path(@school),
                      flash: { error: "#{student.name} n'a pas été mis à jour" }
      end

      private

      def students_params
        params.require(:student).permit(:class_room_id)
      end
    end
  end
end
