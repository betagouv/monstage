# frozen_string_literal: true

module Dashboard::Stepper
  # Step 2 of internship offer creation: fill in offer details/info
  class HostingInfosController < ApplicationController
    before_action :authenticate_user!

    # render step 3
    def new
      authorize! :create, HostingInfo

      @hosting_info = HostingInfo.new
      @organisation = Organisation.find(params[:organisation_id])
      @available_weeks = Week.selectable_from_now_until_end_of_school_year
    end

    # process step 3
    def create
      authorize! :create, HostingInfo
      @hosting_info = HostingInfo.new(
        {}.merge(hosting_info_params)
          .merge(employer_id: current_user.id)
      )
      @hosting_info.save!
      redirect_to(new_dashboard_stepper_tutor_path(
                    organisation_id: params[:organisation_id],
                    internship_offer_info_id: @internship_offer_info.id
      ))
    rescue ActiveRecord::RecordInvalid
      @organisation = Organisation.find(params[:organisation_id])
      @available_weeks = Week.selectable_from_now_until_end_of_school_year
      render :new, status: :bad_request
    end

    # render back to step 3
    def edit
      @internship_offer_info = HostingInfo.find(params[:id])
      @organisation = Organisation.find(params[:organisation_id])
      authorize! :edit, @internship_offer_info
      @available_weeks = Week.selectable_from_now_until_end_of_school_year
    end

    # process update following a back to step 3 (info was created, it's updated)
    def update
      @internship_offer_info = HostingInfo.find(params[:id])
      authorize! :update, @internship_offer_info

      if @hosting_info.update(hosting_info_params)
        redirect_to new_dashboard_stepper_tutor_path(
          organisation_id: params[:organisation_id],
          internship_offer_info_id: @hosting_info.id
        )
      else
        @organisation = Organisation.find(params[:organisation_id])
        @available_weeks = Week.selectable_from_now_until_end_of_school_year
        render :new, status: :bad_request
      end
    end

    private

    def hosting_info_params
      params.require(:hosting_info)
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
              daily_hours: {},
              daily_lunch_break: {},
              week_ids: []
              )
    end
  end
end
