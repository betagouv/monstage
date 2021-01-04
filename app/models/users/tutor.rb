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
    has_many :internship_offer

    def from_api?
      false
    end

    def password_required?
      return false if skip_password_validation
      super
    end

    def name
      "#{first_name} #{last_name}"
    end
  end
end
