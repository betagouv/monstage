# frozen_string_literal: true

module Dashboard::Stepper
  # Step 2 of internship offer creation: fill in offer details/info
  class InternshipOfferInfosController < ApplicationController
    include ThreeFormsHelper
    before_action :authenticate_user!

    # render step 2
    def new
      authorize! :create, InternshipOfferInfo

      @internship_offer_info = InternshipOfferInfo.new
      @organisation = Organisation.find(params[:organisation_id])
      @available_weeks = Week.selectable_from_now_until_end_of_school_year
    end

    # process step 2
    def create
      authorize! :create, InternshipOfferInfo
      @internship_offer_info = InternshipOfferInfo.new(
        {}.merge(internship_offer_info_params)
          .merge(employer_id: current_user.id)
      )
      @internship_offer_info.coordinates = {
        longitude: internship_offer_info_params[:coordinates][:longitude],
        latitude: internship_offer_info_params[:coordinates][:latitude]
      }
      @internship_offer_info.save!
      redirect_to(new_dashboard_stepper_tutor_path(
                    organisation_id: params[:organisation_id],
                    internship_offer_info_id: @internship_offer_info.id),
                  data: { turbo: false }
      )
    rescue ActiveRecord::RecordInvalid
      @organisation = Organisation.find(params[:organisation_id])
      @available_weeks = Week.selectable_from_now_until_end_of_school_year
      render :new, status: :bad_request
    end

    # render back to step 2
    def edit
      @internship_offer_info = InternshipOfferInfo.find(params[:id])
      @organisation = Organisation.find(params[:organisation_id])
      authorize! :edit, @internship_offer_info
      @available_weeks = Week.selectable_from_now_until_end_of_school_year
    end

    # process update following a back to step 2 (info was created, it's updated)
    def update
      @internship_offer_info = InternshipOfferInfo.find(params[:id])
      authorize! :update, @internship_offer_info

      update_button_label = "Modifier les informations de stage"
      @internship_offer = InternshipOffers::WeeklyFramed.find_by(internship_offer_info_id: params[:id])
      @internship_offer_info , @internship_offer = deal_with_max_candidates_change(
        params: internship_offer_info_params,
        internship_offer_info: @internship_offer_info,
        internship_offer: @internship_offer
      )

      @organisation = @internship_offer_info.internship_offer.organisation

      ActiveRecord::Base.transaction do
        if @internship_offer_info.errors.empty? && @internship_offer_info.update(internship_offer_info_params)
          @internship_offer = offer_tree(@internship_offer).synchronize(@internship_offer_info)

          destination = update_destination(
            internship_offer: @internship_offer,
            update_button_label: update_button_label,
            params: params
          )
          redirect_to destination, notice: "Les modifications sont enregistrées",
                                  data:{ turbo: false}
        else
          params[:step] = 2
          @available_weeks = @internship_offer.available_weeks
          render_when_error(update_button_label)
        end
      end
    end



    private

    def update_destination(update_button_label: , params: , internship_offer: )
      internship_offer_info_id = internship_offer.internship_offer_info.id
      # at creation_step 2, when hitting 'next', you update this way ...
      destination = new_dashboard_stepper_tutor_path(
        organisation_id: params[:organisation_id],
        internship_offer_info_id: internship_offer_info_id
      )
      # or with standard update process
      if (params[:commit] == update_button_label)
        # destination = dashboard_internship_offer_three_forms_interface_path(
        #   internship_offer,
        #   step: 2
        # )
        destination = edit_dashboard_internship_offer_path(
          internship_offer,
          step: 2
        )
      end
      destination
    end

    def deal_with_max_candidates_change(params: , internship_offer_info: , internship_offer: )
      return [internship_offer_info, internship_offer] unless max_candidates_will_change?(params: params, internship_offer_info: internship_offer_info)

      approved_applications_count = internship_offer.internship_applications.approved.count
      former_max_candidates = internship_offer.max_candidates
      next_max_candidates = params[:max_candidates].to_i

      if next_max_candidates < approved_applications_count
        error_message = 'Impossible de réduire le nombre de places ' \
                        'de cette offre de stage car ' \
                        'vous avez déjà accepté plus de candidats que ' \
                        'vous n\'allez leur offrir de places.'
        internship_offer_info.errors.add(:max_candidates, error_message)
        # raise ActiveRecord::RecordInvalid, internship_offer_info
      else
        internship_offer.remaining_seats_count = next_max_candidates - approved_applications_count
      end
      [internship_offer_info, internship_offer]
    end

    def max_candidates_will_change?(params: , internship_offer_info: )
      params[:max_candidates] && params[:max_candidates] != internship_offer_info.max_candidates
    end

    def internship_offer_info_params
      params.require(:internship_offer_info)
            .permit(
              :title,
              :employer_type,
              :type,
              :sector_id,
              :school_id,
              :employer_id,
              :description_rich_text,
              :max_candidates,
              :max_students_per_group,
              :manual_enter,
              :employer_name,
              :siret,
              :street,
              :city,
              :zipcode,
              :weekly_lunch_break,
              weekly_hours: [],
              new_daily_hours: {},
              daily_lunch_break: {},
              week_ids: [],
              coordinates: {}
              )
    end
  end
end
