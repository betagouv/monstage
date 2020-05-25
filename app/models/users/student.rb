# frozen_string_literal: true

module Users
  class Student < User
    include UserAdmin

    rails_admin do
      list do
        fields *UserAdmin::DEFAULTS_FIELDS
        field :school do
          pretty_value do
            school = bindings[:object].school
            if school.is_a?(School)
              path = bindings[:view].show_path(model_name: school.class.name, id: school.id)
              bindings[:view].content_tag(:a, school.name, href: path)
            end
          end
        end
      end

      export do
        field :first_name
        field :last_name
        field :confirmed_at
        field :departement, :string do
          export_value do
            bindings[:object].school&.department
          end
        end
      end
    end

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
                                       foreign_key: 'user_id'

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
        .joins(:internship_offer_week)
        .where("internship_offer_weeks.week_id = #{week.id}")
        .map(&:expire!)
    end

    def anonymize
      super

      update_columns(birth_date: nil, gender: nil, class_room_id: nil,
                     resume_educational_background: nil, resume_other: nil, resume_languages: nil,
                     handicap: nil)

      internship_applications.map(&:anonymize)
    end
  end
end
