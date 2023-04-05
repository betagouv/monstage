# frozen_string_literal: true

module Users
  class Student < User
    include StudentAdmin

    belongs_to :school, optional: true

    belongs_to :class_room, optional: true

    has_many :internship_applications, dependent: :destroy, foreign_key: 'user_id'
    has_many :internship_agreements, through: :internship_applications

    # has_many :favorites
    
    # has_many :users_internship_offers
    has_many :internship_offers, through: :favorites

    # has_many :favorite_internship_offers, class_name: 'FavoriteInternshipOffer'
    
    # has_many :internship_offers, through: :favorite_internship_offers, class_name: 'InternshipOffer'
    
    # has_many :users_internship_offers

    scope :without_class_room, -> { where(class_room_id: nil, anonymized: false) }

    has_rich_text :resume_educational_background
    has_rich_text :resume_other
    has_rich_text :resume_languages

    delegate :school_manager,
             to: :school

    validates :birth_date,
              :gender,
              presence: true

    validate :validate_school_presence_at_creation

    attr_reader :handicap_present

    def student?; true end

    def channel
      return :email if email.present?

      :phone
    end

    def has_zero_internship_application?
      internship_applications.all
                             .size
                             .zero?
    end

    def age
      ((Time.zone.now - birth_date.to_time) / 1.year.seconds).floor
    end

    def to_s
      "#{super}, in school: #{school&.zipcode}"
    end

    def after_sign_in_path
      if targeted_offer_id.present?
        url_helpers.internship_offer_path(id: canceled_targeted_offer_id)
      else
        presenter.default_internship_offers_path
      end
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

    def school_manager_email
      school_manager&.email
    end

    # def main_teacher_email
    #   main_teacher&.email
    # end

    def expire_application_on_week(week:, keep_internship_application_id:)
      internship_applications
        .where(aasm_state: %i[approved submitted drafted])
        .not_by_id(id: id)
        .weekly_framed
        .select { |application| application.week.id == week.id }
        .map(&:expire!)
    end

    def main_teacher
      return nil if try(:class_room).nil?

      class_room.school_managements
                &.main_teachers
                &.first
    end

    def anonymize(send_email: true)
      super(send_email: send_email)

      update_columns(birth_date: nil,
                     handicap: nil)
      resume_educational_background.try(:delete)
      resume_other.try(:delete)
      resume_languages.try(:delete)
      internship_applications.map(&:anonymize)
    end

    def validate_school_presence_at_creation
      if new_record? && school.blank?
        errors.add(:school, :blank)
      end
    end

    def presenter
      Presenters::Student.new(self)
    end

    def satisfaction_survey_id
      ENV['TALLY_STUDENT_SURVEY_ID']
    end
  end
end
