# frozen_string_literal: true

module Dashboard::Stepper
  # Step 2 of internship offer creation: fill in offer details/info
  class InternshipOfferInfosController < ApplicationController
    before_action :authenticate_user!

    # render step 2
    def new
      authorize! :create, InternshipOfferInfo

      @internship_offer_info = InternshipOfferInfo.new
      @available_weeks = Week.selectable_from_now_until_end_of_school_year
    end

    # process step 2
    def create
      authorize! :create, InternshipOfferInfo

      @internship_offer_info = InternshipOfferInfo.new(
        {}.merge(internship_offer_info_params)
          .merge(prepare_daily_hours(params))
          .merge(employer_id: current_user.id)
      )
      @internship_offer_info.save!
      redirect_to(new_dashboard_stepper_tutor_path(
                    organisation_id: params[:organisation_id],
                    internship_offer_info_id: @internship_offer_info.id
      ))
    rescue ActiveRecord::RecordInvalid
      @available_weeks = Week.selectable_from_now_until_end_of_school_year
      render :new, status: :bad_request
    end

    # render back to step 2
    def edit
      @internship_offer_info = InternshipOfferInfo.find(params[:id])
      authorize! :edit, @internship_offer_info
      @available_weeks = Week.selectable_from_now_until_end_of_school_year
    end

    # process update following a back to step 2 (info was created, it's updated)
    def update
      @internship_offer_info = InternshipOfferInfo.find(params[:id])
      authorize! :update, @internship_offer_info

      if InternshipOfferInfo.update(internship_offer_info_params.merge!(prepare_daily_hours(params)))
        redirect_to  new_dashboard_stepper_tutor_path(
          organisation_id: params[:organisation_id],
          internship_offer_info_id: @internship_offer_info.id,
        )
      else
        @available_weeks = Week.selectable_from_now_until_end_of_school_year
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
