# frozen_string_literal: true

module Dashboard::Stepper
  # Step 3 of internship offer creation: fill in hosting info
  class HostingInfosController < ApplicationController
    before_action :authenticate_user!

    # render step 3
    def new
      authorize! :create, HostingInfo

      @hosting_info = HostingInfo.new
      @organisation = Organisation.find(params[:organisation_id])
      @internship_offer_info = InternshipOfferInfo.find(params[:internship_offer_info_id])
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
      redirect_to(new_dashboard_stepper_practical_info_path(
                    organisation_id: params[:organisation_id],
                    internship_offer_info_id: params[:internship_offer_info_id],
                    hosting_info_id: @hosting_info.id
      ))
    rescue ActiveRecord::RecordInvalid
      @organisation = Organisation.find(params[:organisation_id])
      @available_weeks = Week.selectable_from_now_until_end_of_school_year
      render :new, status: :bad_request
    end

    # render back to step 3
    def edit
      @hosting_info = HostingInfo.find(params[:id])
      @organisation = Organisation.find(params[:organisation_id])
      authorize! :edit, @hosting_info
      @available_weeks = Week.selectable_from_now_until_end_of_school_year
    end

    # process update following a back to step 3 (info was created, it's updated)
    def update
      @hosting_info = HostingInfo.find(params[:id])
      authorize! :update, @hosting_info

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
              :school_id,
              :employer_id,
              :max_candidates,
              :max_students_per_group,
              week_ids: []
              )
    end
  end
end
