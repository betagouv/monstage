# frozen_string_literal: true

module Dashboard
  module InternshipOffers
    class InternshipApplicationsController < ApplicationController
      before_action :authenticate_user!
      before_action :find_internship_offer, only: %i[index update]

      def index
        authorize! :read, @internship_offer
        authorize! :index, InternshipApplication
        @internship_applications = @internship_offer.internship_applications
                                                    .where.not(aasm_state: %i[drafted expired])
                                                    .includes(:student, :week, :internship_offer, :internship_offer_week)
                                                    .order(updated_at: :desc)
                                                    .page(params[:page])
      end

      def update
        @internship_application = @internship_offer.internship_applications.find(params[:id])
        authorize! :update, @internship_application, InternshipApplication
        @internship_application.send(params[:transition]) if valid_transition?
        redirect_back fallback_location: current_user.after_sign_in_path,
                      flash: { success: 'Candidature mise à jour avec succès' }
      rescue AASM::InvalidTransition
        redirect_back fallback_location: current_user.after_sign_in_path,
                      flash: { warning: 'Cette candidature a déjà été traitée' }
      end

      private

      def valid_transition?
        %w[approve! reject! signed! cancel!].include?(params[:transition])
      end

      def find_internship_offer
        @internship_offer = InternshipOffer.find(params[:internship_offer_id])
      end

      def internship_application_params
        params.require(:internship_application).permit(:motivation, :internship_offer_week_id, :user_id)
      end
    end
  end
end
