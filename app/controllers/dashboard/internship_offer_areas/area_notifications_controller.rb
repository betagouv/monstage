module Dashboard
  module InternshipOfferArea
    class AreaNotificationsController < ApplicationController

      before_action :authenticate_user!
      before_action :set_internship_offer_area

      def index
      end

      def edit
      end

      def update
      end

      private

      def set_internship_offer_area
        @internship_offer_area = current_user.internship_offer_areas.find(params[:internship_offer_area_id])
      end
    end
  end
end