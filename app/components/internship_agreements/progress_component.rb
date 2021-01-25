module InternshipAgreements
  class ProgressComponent < BaseComponent
    private
    attr_reader :internship_agreement, :current_user

    def initialize(internship_agreement:, current_user:)
      @internship_agreement = internship_agreement
      @current_user = current_user
    end
  end
end
