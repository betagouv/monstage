# frozen_string_literal: true

module Dashboard
  module Schools
    class StudentsController < ApplicationController
      include NestedSchool

      def update_by_group
        authorize! :update, @school

        students = params.select { |k, v| k.to_s.match(/\Astudent_\d+/) }
        students.each do |k,v|
          student = @school.students
                           .kept
                           .find(k.split('_').last.to_i)
          if v.blank?
            student.update!(class_room_id: nil)
          elsif student.class_room_id.to_i != v.to_i
            student.update!(class_room_id: v.to_i)
          else
            # noop, keep student in current class_room
          end
        end
        redirect_to(dashboard_school_path(@school),
                    flash: { success: "#{students.to_enum.count} élève(s) mis à jour" })
      end

      private

      def students_params
        params.require(:student).permit(:class_room_id)
      end
    end
  end
end
