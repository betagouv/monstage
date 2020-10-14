# frozen_string_literal: true

module Dashboard
  module Schools
    class StudentsController < ApplicationController
      include NestedSchool

      def update_by_group
        students = params.select { |k, v| k.to_s.match(/\Astudent_\d+/) && v.present? }
        students.each do |k,v|
          student = Users::Student.find(k.split('_').last.to_i)
          student.update(class_room_id: v.to_i)
        end
        redirect_to dashboard_school_class_rooms_path(@school),
                      flash: { success: "#{students.to_enum.count} élève(s) mis à jour" }
      end

      private

      def students_params
        params.require(:student).permit(:class_room_id)
      end
    end
  end
end
