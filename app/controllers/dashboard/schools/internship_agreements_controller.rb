# frozen_string_literal: true

module Dashboard
  module Schools
    class InternshipAgreementsController < ApplicationController
      include NestedSchool

      def index
        authorize! :manage_school_internship_agreements, @school
        @applications_by_class_room = InternshipApplication.joins(:student)
                                                            .includes({student: [:class_room]}, :internship_offer)
                                                            .approved
                                                            .where(student: @school.students)
                                                            .group_by { |application| Presenters::ClassRoom.or_null(application.student.class_room) }
      end

      def update
      end
    end
  end
end
