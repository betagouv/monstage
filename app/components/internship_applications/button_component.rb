module InternshipApplications
  class ButtonComponent < BaseComponent
    attr_reader :internship_application, :current_user, :label
    delegate :internship_agreement, to: :internship_application

    def initialize(internship_application:, current_user:, label: "Editer")
      @internship_application = internship_application
      @current_user = current_user
      @label = label
    end
  end
end
