# frozen_string_literal: true

module Dashboard::Stepper
  # Step 1 of internship offer creation: fill in tutor info
  class TutorsController < ApplicationController
    include ThreeFormsHelper
    before_action :authenticate_user!

    def index
      authorize! :index, InternshipOffer
      current_process = params[:current_process]
      @title = set_title(current_process)
      @internship_offer_info_id = params[:internship_offer_info_id]
      @organisation_id = params[:organisation_id]
      # @internship_offer nil when creation process
      @internship_offer = InternshipOffer.find_by(internship_offer_info_id: @internship_offer_info_id)
      @organisation = Organisation.find(@organisation_id)
      @internship_offer_info = InternshipOfferInfo.find(@internship_offer_info_id)

      # @edit = params[:internship_offer_id].present?
      # if @edit
      #   @internship_offer_id = params[:internship_offer_id]
      #   @internship_offer    = InternshipOffer.find(@internship_offer_id)
      #   # internship_offer_tree = InternshipOfferTree.new(internship_offer: @internship_offer)
      #                                             #  .check_or_create_underlying_objects
      #   # Authorization step
      #   @organisation = internship_offer_tree.organisation
      #   authorize! :index, @organisation
      # end

      params[:checked_tutors_list] = true
      @tutors = current_user.tutors.order(updated_at: :desc)
    end
    # render step 3
    def new
      authorize! :create, InternshipOffer

      current_process = params[:current_process]
      @title = set_title(current_process)
      @internship_offer_id = params[:internship_offer_id]

      user_has_not_checked_list = params[:checked_tutors_list].nil?
      existing_tutors = current_user.tutors.count.positive?
      if existing_tutors && user_has_not_checked_list
        option = {}
        if @internship_offer_id.present?
          @internship_offer = InternshipOffer.find(@internship_offer_id)
          option = {
            internship_offer_id: @internship_offer,
            internship_offer_info_id: @intenship_offer.internship_offer_info_id,
            current_process: current_process
          }
        end
        redirect_to dashboard_stepper_tutors_path(option)
        return
      end

      @tutor = Tutor.new
    end

    # render step 3
    def create
      authorize! :create, InternshipOffer
      @tutor = Tutor.new(tutor_params)
      @tutor.save!
      current_process = params[:current_process]
      if current_process.in?(["offer_update", "offer_duplicate"])
        redirect_to edit_dashboard_internship_offer_path( created_internship_offer,
                                                          step: '3'),
                    notice: 'Le nouveau tuteur est enregistré'
      else
        internship_offer_builder.create_from_stepper(builder_params) do |on|
          on.success do |created_internship_offer|
            redirect_to(internship_offer_path(created_internship_offer, origin: 'dashboard'),
                        flash: { success: 'Votre offre de stage est désormais en ligne, Vous pouvez à tout moment la supprimer ou la modifier.' })
          end
          on.failure do |failed_internship_offer|
            render :new, status: :bad_request
          end
        end
      end
    rescue ActiveRecord::RecordInvalid,
           ActionController::ParameterMissing => e
      @tutor ||= Tutor.new
      render :new, status: :bad_request
    end

    def edit
      @tutor = Tutor.find(params[:id])
      authorize! :update, @tutor
    end

    # process update following a back to step 2 (info was created, it's updated)
    def update
      @tutor = Tutor.find(params[:id])
      authorize! :update, @tutor

      current_process = params[:tutor][:current_process]
      @internship_offer_id = params[:tutor][:internship_offer_id]
      if current_process.in?(["offer_update", "offer_duplicate"])
        # internship_offer edition
        update_button_label = 'Modifier'
        @internship_offer = InternshipOffers::WeeklyFramed.find_by(id: @internship_offer_id)

        ActiveRecord::Base.transaction do
          if @tutor.update(tutor_params)
            # @internship_offer.update(tutor_id: @tutor.id)
            @internship_offer = offer_tree(@internship_offer).synchronize(@tutor)
            destination = edit_dashboard_internship_offer_path(
              @internship_offer,
              step: '3',
              current_process: current_process
            )
            redirect_to destination, notice: "Les modifications de tuteur sont enregistrées.",
                                     data: { turbo: false }
          else
            params[:step] = 3
            render_when_error(update_button_label)
          end
        end
      else
        # internship_offer creation
        if @tutor.update(tutor_params)
          redirect_to edit_internship_offer_path( @internship_offer_id,
                                                  current_process: current_process,
                                                  step: "3"),
                      notice: "Le tuteur est enregistré."
        else
          render :edit, status: :bad_request
        end
      end
    end

    private

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
