# frozen_string_literal: true

module Dashboard
  class InternshipOfferInfosController < ApplicationController
    before_action :authenticate_user!

    def new
      @internship_offer_info = InternshipOfferInfo.new
      #authorize! :create, InternshipOffer
      @available_weeks = Week.selectable_from_now_until_end_of_school_year
    end

    def create
      @internship_offer_info = InternshipOfferInfo.new(internship_offer_info_params)

      if @internship_offer_info.save
        redirect_to new_dashboard_mentor_path(
          organisation_id: params[:internship_offer_info][:organisation_id],
          internship_offer_info_id: @internship_offer_info.id,
        )
      else
        
        render :new
      end
    end

    private
    def internship_offer_info_params
      params.require(:internship_offer_info)
            .permit(
              :title, 
              :employer_type, 
              :type, 
              :sector_id, 
              :school_id, 
              :description_rich_text, 
              :max_candidates,
              week_ids: []
              )
    end
  end
end
