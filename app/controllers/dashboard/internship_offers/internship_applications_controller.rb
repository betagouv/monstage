# frozen_string_literal: true

module Dashboard
  module InternshipOffers
    class InternshipApplicationsController < ApplicationController
      ORDER_WITH_INTERNSHIP_DATE = 'internshipDate'
      before_action :authenticate_user!
      before_action :find_internship_offer, only: %i[index update]

      def index
        authorize! :read, @internship_offer
        authorize! :index, InternshipApplication
        @internship_applications = filter_by_week_or_application_date(
          @internship_offer,
          params[:order]
        )
        @internship_applications = @internship_applications.page(params[:page])
      end

      def update
        @internship_application = @internship_offer.internship_applications.find(params[:id])
        authorize! :update, @internship_application, InternshipApplication
        if valid_transition?
          @internship_application.send(params[:transition])
          @internship_application.update!(optional_internship_application_params)
          redirect_back fallback_location: current_user.custom_dashboard_path,
                        flash: { success: "Candidature mise à jour avec succès. #{extra_message}" }
        else
          redirect_back fallback_location: current_user.custom_dashboard_path,
                        flash: { success: 'Impossible de traiter votre requète, veuillez contacter notre support' }
        end
      rescue AASM::InvalidTransition => e
        redirect_back fallback_location: current_user.custom_dashboard_path,
                      flash: { warning: 'Cette candidature a déjà été traitée' }
      end

      private

      def filter_by_week_or_application_date(internship_offer, params_order)
        return internship_offer.internship_applications.no_date_index unless internship_offer.weekly?

        internship_applications = internship_offer.internship_applications.not_drafted
        if params_order == ORDER_WITH_INTERNSHIP_DATE
          internship_applications.order(
            'week_id ASC',
            'internship_applications.updated_at ASC'
          )
        else
          internship_applications.order(
            'internship_applications.updated_at ASC'
          )
        end
      end

      def valid_transition?
        %w[
          approve!
          reject!
          signed!
          cancel_by_employer!
          cancel_by_student!
        ].include?(params[:transition])
      end

      def extra_message
        extra_message_text = 'Vous pouvez renseigner la convention dès maintenant.'
        extra_message_condition = @internship_application.approved? &&
                                  @internship_application.student.school_track == 'troisieme_generale' &&
                                  can?(:edit, @internship_application.internship_agreement)
        extra_message_condition ? extra_message_text : ''
      end

      def find_internship_offer
        @internship_offer = InternshipOffer.find(params[:internship_offer_id])
      end

      def optional_internship_application_params
        params.permit(internship_application: %i[
                        approved_message
                        canceled_by_employer_message
                        canceled_by_student_message
                        rejected_message
                        type
                        aasm_state
                      ])
              .fetch(:internship_application) { {} }
      end
    end
  end
end
