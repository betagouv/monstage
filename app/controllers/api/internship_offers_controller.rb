# frozen_string_literal: true

module Api
  class InternshipOffersController < ApiBaseController
    include SetInternshipOffers

    before_action :authenticate_api_user!

    def create
    end

    def destroy
    end

    private

    def internship_offer_params
      params.require(:internship_offer)
            .permit(:title, :description, :sector_id, :max_candidates, :max_internship_week_number,
                    :tutor_name, :tutor_phone, :tutor_email, :employer_website, :employer_name,
                    :street, :zipcode, :city, :department, :region, :academy,
                    :is_public, :group,
                    :employer_id, :employer_type, :school_id, :employer_description,
                    operator_ids: [], coordinates: {}, week_ids: [])
    end
  end
end
