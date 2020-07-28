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
        redirect_to new_dashboard_internship_offer_path(mentor_id: @mentor.id)
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
