# frozen_string_literal: true

module Dashboard::Stepper
  # Step 1 of internship offer creation: fill in tutor info
  class TutorsController < ApplicationController
    before_action :authenticate_user!

    # render step 3
    def new
      authorize! :create, InternshipOffer
      @tutor = Users::Tutor.new
    end

    # render step 3
    def create
      byebug
      internship_offer_builder.create_from_stepper(builder_params) do |on|
        on.success do |created_internship_offer|
          redirect_to(internship_offer_path(created_internship_offer, origin: 'dashboard'),
                      flash: { success: 'Votre offre de stage est désormais en ligne, Vous pouvez à tout moment la supprimer ou la modifier.' })
        end
        on.failure do |failed_internship_offer|
          @tutor = failed_internship_offer.tutor
          render :new, status: :bad_request
        end
      end
    rescue ActiveRecord::RecordInvalid,
           ActionController::ParameterMissing
      @tutor ||= Users::Tutor.new
      render :new, status: :bad_request
    end

    private

    def builder_params
      {
        tutor_params: tutor_params,
        internship_offer_info: InternshipOfferInfo.find(params[:internship_offer_info_id]),
        organisation: Organisation.find(params[:organisation_id])
      }
    end

    def tutor_params
      params.require(:tutor)
            .permit(:first_name, :last_name, :phone, :email)
    end

    def internship_offer_builder
      @builder ||= Builders::InternshipOfferBuilder.new(user: current_user,
                                                        context: :web)
    end
  end
end
