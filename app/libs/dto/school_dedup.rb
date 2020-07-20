# frozen_string_literal: true

module Dto
  class SchoolDedup
    def migrate_all
      migrate_users if school.users.count.positive?
      migrate_weeks if school.weeks.count.positive?
      migrate_class_rooms if school.class_rooms.count.positive?
      migrate_internship_offers if InternshipOffer.where(school_id: school.id).count.positive?
      real.save!
      school.reload
      school.destroy!
    end

    def dup?
      !real.nil?
    end

    private

    attr_reader :school, :real

    def migrate_users
      school.users.update_all(school_id: real.id)
    end

    def migrate_weeks
      real.weeks = school.weeks
    end

    def migrate_class_rooms
      school.class_rooms.update_all(school_id: real.id)
    end

    def migrate_internship_offers
      InternshipOffer.where(school_id: school.id).update_all(school_id: real.id)
    end

    def real
      @real ||= School.where(code_uai: school.code_uai)
                      .where.not(id: school.id)
                      .first
    end

    def initialize(school:)
      @school = school
    end
  end
end
