# frozen_string_literal: true

module Users
  class Student < User
    include StudentAdmin

    belongs_to :school, optional: true

    belongs_to :class_room, optional: true

    has_many :internship_applications, dependent: :destroy,
                                       foreign_key: 'user_id' do
      def weekly_framed
        where(type: InternshipApplications::WeeklyFramed.name)
      end
    end
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

    # Callbacks
    after_create :set_reminders

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

    def custom_candidatures_path(parameters={})
      custom_dashboard_path
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

    def needs_to_see_modal?
      internship_applications.validated_by_employer.any?
    end

    def school_and_offer_common_weeks(internship_offer)
      return [] unless school.has_weeks_on_current_year?

      InternshipOfferWeek.applicable(
          school: school,
          internship_offer: internship_offer
        ).map(&:week)
         .uniq
         .sort_by(&:id) & internship_offer.weeks
    end

    def main_teacher
      return nil if try(:class_room).nil?

      class_room.school_managements
                &.main_teachers
                &.first
    end

    def available_offers(max_distance: Finders::ContextTypableInternshipOffer::MAX_RADIUS_SEARCH_DISTANCE)
      Finders::InternshipOfferConsumer.new(user: self, params: {})
                                      .available_offers(max_distance: max_distance)
    end

    def has_offers_to_apply_to?(max_distance: Finders::ContextTypableInternshipOffer::MAX_RADIUS_SEARCH_DISTANCE)
      available_offers(max_distance: max_distance).any?
    end

    def anonymize(send_email: true)
      super(send_email: send_email)

      update_columns(birth_date: nil,
                     current_sign_in_ip: nil,
                     last_sign_in_ip: nil,
                     class_room_id: nil)
      update_columns(phone: 'NA') unless phone.nil?
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

    def has_already_approved_an_application?
      internship_applications.approved.any?
    end

    def log_search_history(search_params)
      search_history = UsersSearchHistory.new(
        keywords: search_params[:keyword],
        latitude: search_params[:latitude],
        longitude: search_params[:longitude],
        city: search_params[:city],
        radius: search_params[:radius],
        results_count: search_params[:results_count],
        user: self
      )
      search_history.save
    end

    def set_reminders
      SendReminderToStudentsWithoutApplicationJob.set(wait: 3.day).perform_later(id)
    end
  end
end
