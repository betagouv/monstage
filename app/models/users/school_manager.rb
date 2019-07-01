# frozen_string_literal: true

module Users
  class SchoolManager < User
    validates :email, format: /\A[^@\s]+@ac-[^@\s]+\z/
    belongs_to :school, optional: true
    has_many :main_teachers, through: :school

    include TargetableInternshipOffersForSchool

    def dashboard_name
      'Mon collège'
    end

    def students_by_class_room_for_registration(ignore_applicants:)
      Rails.logger.info("ignore_applicants: #{ignore_applicants.inspect}")
      school.class_rooms.inject([]) do |class_room_groups, class_room|
        class_room_groups.push([
          class_room.name,
          class_room.students
                    .reject { |student| ignore_applicants.include?(student) }
                    .map { |student| [student.name, student.id]}
        ])
      end
    end

    def after_sign_in_path
      return url_helpers.account_path if school.blank? || school.weeks.empty?

      super
    end

    def custom_dashboard_path
      url_helpers.dashboard_school_class_rooms_path(school)
    rescue StandardError
      url_helpers.account_path
    end

    def dashboard_name
      'Mon Collège'
    end
  end
end
