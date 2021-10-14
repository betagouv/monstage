module Users
  class Tutor < User
    attr_accessor :skip_password_validation

    # Validations
    validates :first_name,
              :last_name,
              :phone,
              :email,
              presence: true,
              unless: :from_api?

    # linked via stepper
    has_many :internship_offers
    has_many :organisations, through: :internship_offers
    has_many :kept_internship_offers, -> (id) { merge(InternshipOffer.kept.where(tutor_id: id)) },
                                      class_name: 'InternshipOffer'
    has_many :internship_applications, through: :kept_internship_offers
    has_many :internship_agreements, through: :internship_applications

    def from_api?
      false
    end

    def password_required?
      return false if skip_password_validation
      super
    end

    def custom_dashboard_path
      url_helpers.dashboard_internship_offers_path
    end

    def custom_agreements_path
      url_helpers.dashboard_internship_applications_path
    end

    def dashboard_name
      'Mes stages'
    end

    def name
      "#{first_name} #{last_name}"
    end

    def store_reset_password_token
      raw, enc = Devise.token_generator.generate(User, :reset_password_token)
      self.reset_password_token = enc
      self.reset_password_sent_at = Time.now.utc
      save(validate: false)
      raw
    end

    def tutor?; true end

  end
end

