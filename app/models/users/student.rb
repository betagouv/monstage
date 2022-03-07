# frozen_string_literal: true

module Users
  class Student < User
    belongs_to :school, optional: true

    belongs_to :class_room, optional: true

    has_many :internship_applications, dependent: :destroy,
                                       foreign_key: 'user_id' do
      def weekly_framed
        where(type: InternshipApplications::WeeklyFramed.name)
      end
    end
    has_many :internship_agreements, through: :internship_applications 

    scope :without_class_room, -> { where(class_room_id: nil, anonymized: false) }

    has_rich_text :resume_educational_background
    has_rich_text :resume_other
    has_rich_text :resume_languages

    delegate :school_track,
             :troisieme_generale?,
             :troisieme_prepa_metiers?,
             :troisieme_segpa?,
             to: :class_room,
             allow_nil: true
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

    def internship_applications_type
      return nil unless class_room.present?
      return InternshipApplications::WeeklyFramed.name if class_room.troisieme_generale?
      return InternshipApplications::FreeDate.name
    end

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
  end
end
