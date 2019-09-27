# frozen_string_literal: true

module Users
  class SchoolManager < User
    include UserAdmin
    rails_admin do
      list do
        field :school do
          pretty_value do
            school = bindings[:object].school
            if school.is_a?(School)
              path = bindings[:view].show_path(model_name: school.class.name, id: school.id)
              bindings[:view].content_tag(:a, school.name, href: path)
            else
              nil
            end
          end
        end
      end
    end

    validates :email, format: /\A[^@\s]+@ac-[^@\s]+\z/
    belongs_to :school, optional: true
    has_many :main_teachers, through: :school

    include TargetableInternshipOffersForSchool

    def students_by_class_room_for_registration(ignore_applicants:)
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
    rescue ActionController::UrlGenerationError
      url_helpers.account_path
    end

    def dashboard_name
      'Mon Collège'
    end
  end
end
