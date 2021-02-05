# frozen_string_literal: true
module Finders
  class TabMainTeacher
    def pending_agreements_count
      # internship_agreement approved with internship_agreement without terms_accepted
      @pending_internship_agreement_count ||= InternshipApplication
                                                    .through_teacher(teacher: main_teacher)
                                                    .approved
                                                    .troisieme_generale
                                                    .joins(:internship_agreement)
                                                    .where(internship_agreement: {main_teacher_accept_terms: false})
                                                    .count

      # internship_applications approved without internship_agreement
      @to_be_created_internnship_agreement ||= InternshipApplication
                                                     .through_teacher(teacher: main_teacher)
                                                     .approved
                                                     .troisieme_generale
                                                     .left_outer_joins(:internship_agreement)
                                                     .where(internship_agreement: {internship_application_id: nil})
                                                     .count
      [
        @pending_internship_agreement_count,
        @to_be_created_internnship_agreement
      ].sum
    end

    def student_without_class_room_count
      return 0 if school.nil?

      @students_without_classs_room_count ||= school.students.without_class_room.count
    end

    private
    attr_reader :main_teacher, :school


    def initialize(main_teacher:)
      @main_teacher = main_teacher
      @school = main_teacher.try(:school)
    end
  end
end
