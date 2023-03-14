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
                        flash: { success: 'Impossible de traiter votre requête, veuillez contacter notre support' }
        end
      rescue AASM::InvalidTransition => e
        redirect_back fallback_location: current_user.custom_dashboard_path,
                      flash: { warning: 'Cette candidature a déjà été traitée' }
      end

      def user_internship_applications
        authorize! :index, Acl::InternshipOfferDashboard.new(user: current_user)
        @internship_offers = current_user.internship_offers
        @internship_applications = fetch_user_internship_applications
      end

      private

      def fetch_user_internship_applications
        InternshipApplications::WeeklyFramed.where(
          internship_offer_id: current_user.internship_offers.ids
        )
      end

      def filter_by_week_or_application_date(internship_offer, params_order)
        includings = %i[ week
                         internship_offer
                         rich_text_motivation
                         internship_agreement
                         rich_text_rejected_message
                         rich_text_canceled_by_employer_message]
        student_includings = %i[school
                                rich_text_resume_languages
                                rich_text_resume_educational_background
                                rich_text_resume_languages
                                rich_text_resume_other]
        internship_applications = InternshipApplications::WeeklyFramed.includes(*includings)
                                                                      .includes(student: [*student_includings])
                                                                      .where(internship_offer: internship_offer)
                                                                      .not_drafted
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
