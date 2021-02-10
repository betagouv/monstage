module InternshipAgreements
  class ButtonComponent < BaseComponent
    attr_reader :internship_application, :current_user
    delegate :internship_agreement, to: :internship_application

    def initialize(internship_application:, current_user:)
      @internship_application = internship_application
      @current_user = current_user
    end
  end
end
