module Dashboard
  # WIP, not yet implemented, will host agreement signing
  class InternshipAgreementsController < ApplicationController

    def new
      @internship_agreement = InternshipAgreement.new(internship_application_id: params[:internship_application_id])
    end

    def create
      # set_internship_offer
      # authorize! :create_agreement, @internship_offer
      @internship_agreement = InternshipAgreement.create!(internship_agreement_params)
      redirect_to dashboard_internship_agreement_path(@internship_agreement)
    end

    def show
      @internship_agreement = InternshipAgreement.find(params[:id])
    end

    private

    # TBD
    def internship_agreement_params
      params.require(:internship_agreement)
            .permit(
              :internship_offer_id,
              :school_id)
              # :employer_type,
              # :student_id)
              # :employer_name,
              # :is_public,
              # :group_id)
              # :tutor_name,
              # :tutor_email,
              # :tutor_email)
    end
  end
end
