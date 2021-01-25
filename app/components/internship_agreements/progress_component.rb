module InternshipAgreements
  class ProgressComponent < BaseComponent
    def curret_role(role_attribute_name:)
      matches = role_attribute_name.to_s.match(/(?<role>.*)_accept_terms/)
      raise ArgumentError, "#{user.type} does not support accept terms yet " if matches[:role].empty?
      matches[:role]
    end

    private
    attr_reader :internship_agreement, :current_user

    def initialize(internship_agreement:, current_user:)
      @internship_agreement = internship_agreement
      @current_user = current_user
    end
  end
end
