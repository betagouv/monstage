# frozen_string_literal: true

module Dashboard::Stepper
  class OrganisationsController < ApplicationController
    before_action :authenticate_user!

    def new
      authorize! :create, Organisation

      @organisation = Organisation.new
    end

    def create
      authorize! :create, Organisation

      @organisation = Organisation.new(organisation_params)
      if @organisation.save
        redirect_to new_dashboard_stepper_internship_offer_info_path(organisation_id: @organisation.id)
      else
        render :new, status: :bad_request
      end
    end

    private
    def organisation_params
      params.require(:organisation)
            .permit(
              :name,
              :street,
              :zipcode,
              :city,
              :description_rich_text,
              :website,
              :is_public,
              :group_id,
              :organisation_autocomplete,
              coordinates: {})
    end
  end
end
