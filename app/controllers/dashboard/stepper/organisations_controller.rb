# frozen_string_literal: true

module Dashboard::Stepper
  # Step 1 of internship offer creation: fill in company info
  class OrganisationsController < ApplicationController
    before_action :authenticate_user!
    before_action :clean_params, only: [:create, :update]

    # render step 1
    def new
      authorize! :create, Organisation

      @organisation = Organisation.new
    end

    # process step 1
    def create
      authorize! :create, Organisation      

      @organisation = Organisation.find_by(siret: organisation_params[:siret])
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
    def update
      @organisation = Organisation.find(params[:id])
      authorize! :update, @organisation

      if @organisation.update!(organisation_params)
        redirect_to new_dashboard_stepper_internship_offer_info_path(organisation_id: @organisation.id)
      else
        render :new, status: :bad_request
      end
    end

    private
    def organisation_params
      params.require(:organisation)
            .permit(
              :employer_name,
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
              coordinates: {})
            .merge(employer_id: current_user.id)
    end

    def clean_params
      params[:organisation][:street] = [params[:organisation][:street], params[:organisation][:street_complement]].compact_blank.join(' - ')
    end
  end
end
