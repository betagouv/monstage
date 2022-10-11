module Presenters
  class InternshipAgreement

    # def delegation_date
    #   date = internship_agreement.school_delegation_to_sign_delivered_at
    #   if date.present?
    #     date.strftime("%d/%m/%Y")
    #   else
    #     " DATE A INSCRIRE PAR LE CHEF D'ETABLISSEMENT "
    #   end
    # end
    protected

    attr_reader :internship_agreement, :school_manager, :school, :employer, :student

    def initialize(internship_agreement)
      @internship_agreement = internship_agreement
      @student = internship_agreement.student
      @school_manager = internship_agreement.school_manager
      @school = @school_manager.school
      @employer = internship_agreement.employer
    end
  end
end