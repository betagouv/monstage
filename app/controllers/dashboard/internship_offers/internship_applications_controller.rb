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
                                                    .where.not(aasm_state: [:drafted])
                                                    .includes(:student, :week, :internship_offer, :internship_offer_week)
                                                    .order(updated_at: :desc)
                                                    .page(params[:page])
      end

      def update
        @internship_application = @internship_offer.internship_applications.find(params[:id])
        authorize! :update, @internship_application, InternshipApplication
        if valid_transition?
          @internship_application.send(params[:transition])
          @internship_application.update!(optional_internship_application_params)
          redirect_back fallback_location: current_user.after_sign_in_path,
                        flash: { success: 'Candidature mise à jour avec succès' }
        else
          redirect_back fallback_location: current_user.after_sign_in_path,
                        flash: { success: 'Impossible de traiter votre requète, veuillez contacter notre support' }
        end
      rescue AASM::InvalidTransition => e
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

      def optional_internship_application_params
        params.fetch(:internship_application) { {} }
              .permit(:approved_message,
                      :canceled_message,
                      :rejected_message,
                      :aasm_state)
      end
    end
  end
end
