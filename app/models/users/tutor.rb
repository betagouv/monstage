module Users
  class Tutor < User
    attr_accessor :skip_password_validation
    include StepperProxy::Tutor

    # for ACL
    belongs_to :organisation

    # linked via stepper
    # belongs_to :internship_offer, optional: true

    def from_api?
      false
    end

    def password_required?
      return false if skip_password_validation
      super
    end
  end
end
