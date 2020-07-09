# frozen_string_literal: true

module Users
  class Student < User
    belongs_to :school
    belongs_to :missing_school_weeks, optional: true,
                                      foreign_key: 'missing_school_weeks_id',
                                      class_name: 'School',
                                      counter_cache: :missing_school_weeks_count

    belongs_to :class_room, optional: true
    validates :birth_date,
              :gender,
              presence: true

    has_many :internship_applications, dependent: :destroy,
                                       foreign_key: 'user_id' do
      def weekly_framed
        where(type: InternshipApplications::WeeklyFramedApplication.name)
      end
    end

    has_rich_text :resume_educational_background
    has_rich_text :resume_other
    has_rich_text :resume_languages

    attr_reader :handicap_present

    def has_zero_internship_application?
      internship_applications.all
                             .size
                             .zero?
    end

    def has_convention_signed_internship_application?
      internship_applications.any?(&:convention_signed?)
    end

    def has_approved_internship_application?
      internship_applications.any?(&:approved?)
    end

    def age
      ((Time.zone.now - birth_date.to_time) / 1.year.seconds).floor
    end

    def to_s
      "#{super}, in school: #{school&.zipcode}"
    end

    def custom_dashboard_path
      url_helpers.dashboard_students_internship_applications_path(self)
    end

    def dashboard_name
      'Candidatures'
    end

    def default_account_section
      'resume'
    end

    def expire_application_on_week(week:, keep_internship_application_id:)
      internship_applications
        .where(aasm_state: %i[approved submitted drafted])
        .not_by_id(id: id)
        .weekly_framed
        .select { |application| application.week.id == week.id }
        .map(&:expire!)
    end

    def anonymize
      super

      update_columns(birth_date: nil, gender: nil, class_room_id: nil,
                     handicap: nil)
      self.resume_educational_background.try(:delete)
      self.resume_other.try(:delete)
      self.resume_languages.try(:delete)
      internship_applications.map(&:anonymize)
    end
  end
end
