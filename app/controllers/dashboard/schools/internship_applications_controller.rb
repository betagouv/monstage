# frozen_string_literal: true

module Dashboard
  module Schools
    class InternshipApplicationsController < ApplicationController
      include NestedSchool

      def index
        authorize! :manage_school_internship_agreements, @school
        applications_for_school_managers if current_user.role == 'school_manager'
        applications_for_main_teachers   if current_user.role == 'main_teacher'
      end

      def applications_for_school_managers
        @applications_by_class_room ||= group_by_class_room do
          @school.internship_applications
                 .approved
                 .troisieme_generale
        end
      end

      def applications_for_main_teachers
        @applications_by_class_room ||= group_by_class_room do
          InternshipApplication.approved
                               .troisieme_generale
                               .through_teacher(teacher: current_user)
        end
      end

      def group_by_class_room
        query = yield
        query.group_by do |application|
          Presenters::ClassRoom.or_null(application.student.class_room)
        end
      end
    end
  end
end
