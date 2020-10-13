# frozen_string_literal: true

module NestedSchool
  extend ActiveSupport::Concern

  included do
    before_action :set_school
    before_action :authenticate_user!

    def set_school
      @school = School.find(params.require(:school_id))
    end

    def navbar_badges
      @applications = InternshipApplication.joins(:student)
                                            .includes({student: [:class_room]}, :internship_offer)
                                            .approved
                                            .where(student: @school.students)
      @students_without_class_room = @school.students
                                            .where(anonymized: nil)
                                            .where(class_room_id: nil)
    end
  end
end
