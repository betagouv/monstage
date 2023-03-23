# frozen_string_literal: true

module Dashboard::Stepper
  # Step 2 of internship offer creation: fill in offer details/info
  class InternshipOfferInfosController < ApplicationController
    before_action :authenticate_user!
    before_action :fetch_internship_offer_info, only: %i[edit update]

    # render step 2
    def new
      authorize! :create, InternshipOfferInfo

      @internship_offer_info = InternshipOfferInfos::WeeklyFramed.new
      @organisation = Organisation.find(params[:organisation_id])
      @available_weeks = Week.selectable_from_now_until_end_of_school_year
    end

    # process step 2
    def create
      authorize! :create, InternshipOfferInfo
      @internship_offer_info = InternshipOfferInfos::WeeklyFramed.new(
        {}.merge(internship_offer_info_params)
          .merge(employer_id: current_user.id)
      )
      @internship_offer_info.save!
      redirect_to(new_dashboard_stepper_tutor_path(
                    organisation_id: params[:organisation_id],
                    internship_offer_info_id: @internship_offer_info.id
      ))
    rescue ActiveRecord::RecordInvalid
      @organisation = Organisation.find(params[:organisation_id])
      @available_weeks = Week.selectable_from_now_until_end_of_school_year
      render :new, status: :bad_request
    end

    # render back to step 2
    def edit
      authorize! :edit, @internship_offer_info
      @organisation = Organisation.find(params[:organisation_id])
      @available_weeks = Week.selectable_from_now_until_next_school_year
    end

    # process update following a back to step 2 (info was created, it's updated)
    def update
      authorize! :update, @internship_offer_info

      if @internship_offer_info.update(internship_offer_info_params)
        redirect_to new_dashboard_stepper_tutor_path(
          organisation_id: params[:organisation_id],
          internship_offer_info_id: @internship_offer_info.id
        )
      else
        @organisation = Organisation.find(params[:organisation_id])
        @available_weeks = Week.selectable_from_now_until_next_school_year
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
              :max_students_per_group,
              :siret,
              :weekly_lunch_break,
              weekly_hours: [],
              new_daily_hours: {},
              daily_lunch_break: {},
              week_ids: []
              )
    end

    def fetch_internship_offer_info
      @internship_offer_info = InternshipOfferInfos::WeeklyFramed.find(params[:id])
    end
  end
end
