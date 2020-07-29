# frozen_string_literal: true

module Dashboard
  class MentorsController < ApplicationController
    before_action :authenticate_user!

    def new
      @mentor = Mentor.new
    end

    def create
      @mentor = Mentor.new(mentor_params)
      if @mentor.save
        InternshipOffer.create_with_params(params[:mentor][:organisation_id], params[:mentor][:internship_offer_info_id], @mentor.id)
        redirect_to dashboard_internship_offers_path,
          flash: { success: t('dashboard.internship_offer.created') }
      else
        render :new
      end
    end

    private
    def mentor_params
      params.require(:mentor)
            .permit(
              :name,
              :email,
              :phone)
    end
  end
end
