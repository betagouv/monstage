# frozen_string_literal: true
module Finders
  class TabSchoolManager
    def pending_class_rooms_actions_count
      school.students.without_class_room.count
    end

    def pending_agreements_count
      internship_agreements = InternshipAgreement.joins(internship_application: {student: :school})
                                                 .where(school: {id: school.id})
      states_with_actions= %i[completed_by_employer started_by_school_manager validated]
      count = internship_agreements.where(aasm_state: states_with_actions).count
      count += internship_agreements.signatures_started
                                    .joins(:signatures)
                                    .where.not(signatures: {signatory_role: :school_manager} )
                                    .count
    end

    def student_without_class_room_count
      school.students.without_class_room.count
    end

    private

    attr_reader :school

    def initialize(school:)
      @school = school
    end
  end
end
