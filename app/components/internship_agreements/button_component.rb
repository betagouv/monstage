module InternshipAgreements
  class ButtonComponent < ApplicationComponent
    delegate :internship_agreement, to: :internship_application

    delegate :main_teacher_accept_terms?,
             :school_manager_accept_terms?,
             :employer_accept_terms?,
             :troisieme_generale?,
             to: :internship_agreement

    def ready_to_print?
      signed_count == signatures_count_required
    end

    def confirmed_by_current_user?
      return false unless internship_agreement
      return school_manager_accept_terms? if current_user.school_manager?
      return main_teacher_accept_terms? if current_user.main_teacher?
      return employer_accept_terms? if current_user.is_a?(Users::Employer)
      raise  ArgumentError, "#{current_user.type} does not support accept terms yet "
    end

    def signed_count
      required_signatures.map { |attr_name| self.send("#{attr_name}") }
                         .select { |value| value == true}
                         .size
    end

    def signatures_count_required
      required_signatures.size
    end

    def required_signatures
      signatures = [
        :employer_accept_terms?,
        :school_manager_accept_terms?
      ]
      signatures = signatures.concat(:main_teacher_accept_terms?) unless troisieme_generale?
      signatures
    end

    private
    attr_reader :internship_application, :current_user

    def initialize(internship_application:, current_user:)
      @internship_application = internship_application
      @current_user = current_user
    end
  end
end
