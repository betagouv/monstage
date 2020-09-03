# frozen_string_literal: true

module Dashboard
  class InternshipOfferInfosController < ApplicationController
    before_action :authenticate_user!

    def new
      @internship_offer_info = InternshipOfferInfo.new
      #authorize! :create, InternshipOfferInfo
      @available_weeks = Week.selectable_from_now_until_end_of_school_year
      @organisation_id = params[:organisation_id]
    end

    def create
      @internship_offer_info = InternshipOfferInfo.new(internship_offer_info_params.merge!(prepare_daily_hours(params)))
      organisation_id = params[:internship_offer_info][:organisation_id]

      if @internship_offer_info.save
        redirect_to new_dashboard_internship_offer_path(
          organisation_id: organisation_id,
          internship_offer_info_id: @internship_offer_info.id,
        )
      else
        @available_weeks = Week.selectable_from_now_until_end_of_school_year
        @organisation_id = organisation_id
        render :new, status: :bad_request
      end
    end

    def edit
      @internship_offer_info = InternshipOfferInfo.find(params[:id])
      #authorize! :create, InternshipOfferInfo
      @available_weeks = Week.selectable_from_now_until_end_of_school_year
      @organisation_id = params[:organisation_id]
    end

    def update
      @internship_offer_info = InternshipOfferInfo.find(params[:id])
      organisation_id = params[:internship_offer_info][:organisation_id]

      if InternshipOfferInfo.update(internship_offer_info_params.merge!(prepare_daily_hours(params)))
        redirect_to new_dashboard_internship_offer_path(
          organisation_id: organisation_id,
          internship_offer_info_id: @internship_offer_info.id,
        )
      else
        @available_weeks = Week.selectable_from_now_until_end_of_school_year
        @organisation_id = organisation_id
        render :new, status: :bad_request
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
              :employer_id,
              :description_rich_text, 
              :max_candidates,
              :weekly_start,
              :weekly_end,
              :daily_hours,
              week_ids: []
              )
    end

    def prepare_daily_hours(params)
      if params[:weekly_start].present? && params[:weekly_end].present?
        { weekly_hours: [params[:weekly_start], params[:weekly_end]] }
      else
        daily_planning_hours = (0..5).map { |i| [params["daily_start_#{i}".to_sym], params["daily_end_#{i}".to_sym]] }
        { daily_hours: daily_planning_hours }
      end
    end
  end
end
