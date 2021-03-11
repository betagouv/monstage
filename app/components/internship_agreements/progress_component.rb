module InternshipAgreements
  class ProgressComponent < BaseComponent
   def curret_role(role_attribute_name:)
      matches = role_attribute_name.to_s.match(/(?<role>.*)_accept_terms/)
      raise ArgumentError, "#{user.type} does not support accept terms yet " if matches[:role].empty?

      matches[:role]
    end

    private
    attr_reader :internship_agreement, :current_user, :custom_classes

    def initialize(internship_agreement:, current_user:, custom_classes: "")
      @internship_agreement = internship_agreement
      @current_user = current_user
      @custom_classes = custom_classes
    end
  end
end
