module Dashboard
  class InternshipAgreementsController < ApplicationController

    def new
      # byebug
      @internship_agreement = InternshipAgreement.new(internship_application_id: params[:internship_application_id])
    end

    def create
      # set_internship_offer
      # authorize! :create_agreement, @internship_offer
      # byebug
      p 'params'
      p params
      p internship_agreement_params

      @internship_agreement = InternshipAgreement.create!(internship_agreement_params)
      redirect_to dashboard_internship_agreement_path(@internship_agreement)
    end

    def show
      # byebug
      @internship_agreement = InternshipAgreement.find(params[:id])
    end

    private

    def internship_agreement_params
      params.require(:internship_agreement)
            .permit(
              # :employer_id, 
              # :employer_type, 
              :internship_offer_id,
              :school_id)
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