# frozen_string_literal: true

module Dashboard::Stepper
  # Step 1 of internship offer creation: fill in company info
  class OrganisationsController < ApplicationController
    include ThreeFormsHelper
    before_action :authenticate_user!

    # render step 1
    def new
      authorize! :create, Organisation

      @organisation = Organisation.new
    end

    # process step 1
    def create
      authorize! :create, Organisation

      if organisation_params[:siret].present?
        @organisation = Organisation.find_by(siret: organisation_params[:siret])
      end
      @organisation ||= Organisation.new(organisation_params)

      if @organisation.save
        redirect_to new_dashboard_stepper_internship_offer_info_path(organisation_id: @organisation.id)
      else
        render :new, status: :bad_request
      end
    end

    # TODO: edit/update. other back does not works. which is missing

    # render back to step 1
    def edit
      @organisation = Organisation.find(params[:id])
      authorize! :edit, @organisation
    end

    # process update following a back to step 1
    # or
    # by internship_offer update process
    def update
      @organisation = Organisation.find(params[:id])
      authorize! :update, @organisation

      update_button_label = 'Modifier le siège'
      was_interpolated = @organisation.db_interpolated?
      @internship_offer = InternshipOffers::WeeklyFramed.find_by(organisation_id: @organisation.id)
      parameters = organisation_params.merge!(db_interpolated: false)
      ActiveRecord::Base.transaction do
        if @organisation.update(parameters)
          @internship_offer = offer_tree(@internship_offer).synchronize(@organisation)
          destination = update_destination(
            params: params,
            update_button_label: update_button_label,
            internship_offer: @internship_offer
          )
          redirect_to destination, notice: notice(was_interpolated), data:{ turbo: false}
        else
          params[:step] = 1
          @available_weeks = @internship_offer.available_weeks
          render_when_error(update_button_label)
        end
      end
    end

    private

    def update_destination(update_button_label: , params: , internship_offer: )
      # process for new organisations update following a back to step 1 from step 2
      destination = new_dashboard_stepper_internship_offer_info_path(organisation_id: internship_offer.organisation.id)
      #  or standard update process
      if (params[:commit] == update_button_label)
        # destination = dashboard_internship_offer_three_forms_interface_path(
        #   internship_offer_id: internship_offer.id,
        #   step: '1'
        # )
        destination = edit_dashboard_internship_offer_path(
          internship_offer,
          step: '1'
        )
      end
      destination
    end

    def organisation_params
      params.require(:organisation)
            .permit(
              :employer_name,
              :coordinates,
              :street,
              :zipcode,
              :city,
              :siret,
              :manual_enter,
              :employer_description_rich_text,
              :employer_website,
              :is_public,
              :group_id,
              :autocomplete,
              :db_interpolated,
              coordinates: {})
            .merge(employer_id: current_user.id)
    end

    def notice(was_interpolated)
      notice = "Les modifications sont enregistrées."
      extended_notice = "#{notice} Les onglets 'Modifier le stage' et 'Modifier' " \
                        "le tuteur de stage' sont maintenant disponibles en haut de page"
      was_interpolated ? extended_notice : notice
    end
  end
end
