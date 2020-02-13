# frozen_string_literal: true

module Users
  class Student < User
    include UserAdmin
    rails_admin do
      list do
        field :school
      end

      edit do
        field :has_parental_consent
      end

      show do
        field :class_room
      end

      export do
        field :first_name
        field :last_name
        field :confirmed_at
        field :has_parental_consent
        field :departement, :string do
          export_value do
            bindings[:object].school&.department
          end
        end
      end
    end

    belongs_to :school
    belongs_to :class_room, optional: true
    validates :birth_date,
              :gender,
              presence: true

    has_many :internship_applications, dependent: :destroy,
                                       foreign_key: 'user_id'

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

    # Block sign in if email is not confirmed and main teacher has not confirmed
    # that he received parental consent.
    def active_for_authentication?
      super && confirmed? && has_parental_consent?
    end

    def inactive_message
      return :unconfirmed if !confirmed?
      return :not_approved if !has_parental_consent

      super
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

    def cancel_application_on_week(week:, keep_internship_application_id:)
      internship_applications
        .where(aasm_state: %i[approved submitted drafted])
        .not_by_id(id: id)
        .joins(:internship_offer_week)
        .where("internship_offer_weeks.week_id = #{week.id}")
        .map(&:cancel!)
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
