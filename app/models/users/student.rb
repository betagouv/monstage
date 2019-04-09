module Users
  class Student < User
    belongs_to :school
    belongs_to :class_room, optional: true
    validates :birth_date,
              :gender,
              presence: true

    include TargetableInternshipOffersForSchool


    has_many :internship_applications, dependent: :destroy, foreign_key: 'user_id'
    after_initialize :init

    def has_zero_internship_application?
      internship_applications.count.zero?
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

    def init
      self.birth_date ||= 14.years.ago
    end

    # Block sign in if email is not confirmed and main teacher has not confirmed
    # that he received parental consent.
    def active_for_authentication?
      super && confirmed? && has_parental_consent?
    end

    def inactive_message
      !confirmed? ? :unconfirmed : (has_parental_consent? ? super : :not_approved)
    end

    def after_sign_in_path
      custom_dashboard_path
    end

    def custom_dashboard_path
      return url_helpers.dashboard_path
    end
  end
end
