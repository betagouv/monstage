# frozen_string_literal: true

module Dashboard
  class OrganisationsController < ApplicationController
    before_action :authenticate_user!

    def new
      @organisation = Organisation.new
    end

    def create
    end

    private
    def organisation_params
      params.require(:organisation)
            .permit(
              :name,
              :street,
              :address_2,
              :zip_code,
              :city,
              :description,
              :website,
              :is_public,
              :coordinates)
    end
  end
end
