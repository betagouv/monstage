# frozen_string_literal: true

module Dashboard::Stepper
  # Step 1 of internship offer creation: fill in tutor info
  class TutorsController < ApplicationController
    include ThreeFormsHelper
    before_action :authenticate_user!

    # render step 3
    def new
      authorize! :create, InternshipOffer
      @tutor = Tutor.new
    end

    # render step 3
    def create
      @tutor = Tutor.new(tutor_params)
      @tutor.save!
      internship_offer_builder.create_from_stepper(builder_params) do |on|
        on.success do |created_internship_offer|
          redirect_to(internship_offer_path(created_internship_offer, origin: 'dashboard'),
                      flash: { success: 'Votre offre de stage est désormais en ligne, Vous pouvez à tout moment la supprimer ou la modifier.' })
        end
        on.failure do |failed_internship_offer|
          render :new, status: :bad_request
        end
      end
    rescue ActiveRecord::RecordInvalid,
           ActionController::ParameterMissing => e
      @tutor ||= Tutor.new
      render :new, status: :bad_request
    end

    # process update following a back to step 2 (info was created, it's updated)
    def update
      @tutor = Tutor.find(params[:id])
      authorize! :update, @tutor

      update_button_label = "Modifier les informations du tuteur"
      @internship_offer = InternshipOffers::WeeklyFramed.find_by(tutor_id: params[:id])

      if @tutor.update(tutor_params)
        @internship_offer = offer_tree(@internship_offer).synchronize(@tutor)

        destination = update_destination(
          params: params,
          update_button_label: update_button_label,
          internship_offer: @internship_offer
        )
        redirect_to destination, notice: "Les modifications sont enregistrées",
                                 data:{ turbo: false}
      else
        params[:step] = 3
        @available_weeks = @internship_offer.available_weeks
        render_when_error(update_button_label)
      end
    end

    private

    def update_destination(update_button_label: , params: , internship_offer: )
      # at creation_step 3, when hitting 'back', you update this way ...
      destination = new_dashboard_stepper_tutor_path(
        organisation_id: params[:organisation_id],
        internship_offer_info_id: params[:internship_offer_info_id]
      )
      # or with standard update process
      if (params[:commit] == update_button_label)
        destination = edit_dashboard_internship_offer_path(
          internship_offer,
          step: '3'
        )
      end
      destination
    end

    def builder_params
      {
        tutor: @tutor,
        internship_offer_info: InternshipOfferInfo.find(params[:internship_offer_info_id]),
        organisation: Organisation.find(params[:organisation_id])
      }
    end

    def tutor_params
      params.require(:tutor)
            .permit(:tutor_name, :tutor_phone, :tutor_email, :tutor_role,:db_interpolated)
            .merge(employer_id: current_user.id)
    end

    def internship_offer_builder
      @builder ||= Builders::InternshipOfferBuilder.new(user: current_user,
                                                        context: :web)
    end
  end
end
