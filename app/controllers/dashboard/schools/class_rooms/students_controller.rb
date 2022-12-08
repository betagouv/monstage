# frozen_string_literal: true

module Dashboard
  module Schools::ClassRooms
    class StudentsController < ApplicationController
      include NestedSchool

      def index
        authorize! :manage_school_students, current_user.school

        @class_room = @school.class_rooms.find(params.require(:class_room_id))
        @students = @class_room.students.kept
                               .includes([:school, :internship_applications])
                               .order(:last_name, :first_name)
      end

      def new
        authorize! :manage_school_students, current_user.school

        @class_room = @school.class_rooms.find(params.require(:class_room_id))
        @student = Users::Student.new
        @students = @class_room.students.kept #TO DO created_today
                               .includes([:school, :internship_applications])
                               .order(:last_name, :first_name)
      end

      def create
        authorize! :manage_school_students, current_user.school
        @class_room = @school.class_rooms.find(params.require(:class_room_id))
        student = Users::Student.new(formatted_student_params)
        if student.save
          token = student.create_reset_password_token
          StudentMailer.account_created_by_teacher(teacher: current_user, student: student, token: token).deliver_later
          redirect_to new_dashboard_school_class_room_student_path(@class_room.school, @class_room), notice: 'Elève créé !'
        else
          puts student.errors.full_messages
          redirect_to new_dashboard_school_class_room_student_path(@class_room.school, @class_room), flash: { danger: 'Erreur : Elève non créé.' }
        end
      end


      private

      def students_params
        params.require(:users_student).permit(
          :first_name,
          :last_name,
          :email,
          :phone,
          :birth_date,
          :gender,
          :handicap,
          :class_room_id,
          :school_id
        )
      end

      def formatted_student_params
        students_params.merge(
          school_id: @class_room.school_id, 
          class_room_id: @class_room_id,
          accept_terms: true,
          password: Devise.friendly_token.first(8),
          created_by_teacher: true,
        )
      end

    end
  end
end
