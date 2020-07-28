# frozen_string_literal: true

module Dashboard
  class OrganisationsController < ApplicationController
    before_action :authenticate_user!

    def new
      @organisation = Organisation.new
    end

    def create
      @organisation = Organisation.new(organisation_params)
      if @organisation.save
        redirect_to new_dashboard_internship_offer_path(organisation_id: @organisation.id)
      else
        
        render :new
      end
    end

    private
    def organisation_params
      params.require(:organisation)
            .permit(
              :name,
              :street,
              :address_2,
              :zipcode,
              :city,
              :description,
              :website,
              :is_public,
              coordinates: {})
    end
  end
end
