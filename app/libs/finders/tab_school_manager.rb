# frozen_string_literal: true
module Finders
  class TabSchoolManager

    def pending_agreements_count
      # internship_agreement approved with internship_agreement without terms_accepted
      @pending_internship_agreement_count ||= school.internship_applications
                                                    .approved
                                                    .troisieme_generale
                                                    .joins(:internship_agreement)
                                                    .where(internship_agreement: {aasm_state: :completed_by_employer})
                                                    .count
    end

    def student_without_class_room_count
      @students_without_classs_room_count ||= school.students.without_class_room.count
    end

    private
    attr_reader :school


    def initialize(school:)
      @school = school
    end
  end
end
