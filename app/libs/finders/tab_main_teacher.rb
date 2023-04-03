# frozen_string_literal: true
module Finders
  class TabMainTeacher
    def pending_class_rooms_actions_count
      school.nil? ? 0 : school.students.without_class_room.count
    end
    
    def pending_agreements_count
      # internship_agreement approved with internship_agreement without terms_accepted
      @pending_internship_agreement_count ||= InternshipApplication
                                                    .through_teacher(teacher: main_teacher)
                                                    .approved
                                                    .joins(:internship_agreement)
                                                    .where(internship_agreement: {main_teacher_accept_terms: false})
                                                    .count

      # internship_applications approved without internship_agreement
      @to_be_created_internnship_agreement ||= InternshipApplication
                                                     .through_teacher(teacher: main_teacher)
                                                     .approved
                                                     .left_outer_joins(:internship_agreement)
                                                     .where(internship_agreement: {internship_application_id: nil})
                                                     .count
      [
        @pending_internship_agreement_count,
        @to_be_created_internnship_agreement
      ].sum
    end

    private
    attr_reader :main_teacher, :school


    def initialize(main_teacher:)
      @main_teacher = main_teacher
      @school = main_teacher.try(:school)
    end
  end
end
