# frozen_string_literal: true

module Dashboard
  module InternshipOffers
    class InternshipApplicationsController < ApplicationController
      include ApplicationTransitable

      ORDER_WITH_INTERNSHIP_DATE = 'internshipDate'
      before_action :authenticate_user!, except: %i[update show]
      before_action :find_internship_offer, only: %i[index update show]
      before_action :fetch_internship_application, only: %i[update show set_to_read school_details]

      def index
        authorize! :read, @internship_offer
        authorize! :index, InternshipApplication
        @internship_applications = filter_by_week_or_application_date(
          @internship_offer,
          params[:order]
        )
        @internship_applications = @internship_applications.filtering_discarded_students
                                                           .page(params[:page])
        @internship_offer_areas = current_user.internship_offer_areas
      end

      def set_to_read
        authorize! :update, @internship_application, InternshipApplication
        @internship_application.read! if @internship_application.submitted?
        redirect_to dashboard_internship_offer_internship_application_path(
          @internship_application.internship_offer,
          @internship_application
        )
      end

      def user_internship_applications
        authorize! :index, Acl::InternshipOfferDashboard.new(user: current_user)
        @internship_offers = current_user.internship_offers
        @internship_applications = fetch_user_internship_applications.filtering_discarded_students
        @internship_offer_areas = current_user.internship_offer_areas
        @received_internship_applications = @internship_applications.where(aasm_state: InternshipApplication::RECEIVED_STATES)
        @approved_internship_applications = @internship_applications.where(aasm_state: InternshipApplication::APPROVED_STATES)
        @rejected_internship_applications = @internship_applications.where(aasm_state: InternshipApplication::REJECTED_STATES)
      end

      # magic_link_tracker is not updated here
      def show
        if params[:sgid].present?
          internship_application = InternshipApplication.from_sgid(params[:sgid])
          if internship_application.nil?
            flash_error_message = 'Le lien a expiré, veuillez vous identifier pour accéder à la candidature.'
            path = dashboard_internship_offer_internship_application(
              internship_application.internship_offer,
              internship_application)
            redirect_to path, flash: { danger: flash_error_message } and return
          else
            sign_in(internship_application.employer)
            authorize! :show, InternshipApplication
          end
        elsif params[:token].present?
          unless current_user || authorize_through_token?
            redirect_to root_path, flash: { error: 'Vous n’avez pas accès à cette candidature' } and return
          end
          #no control here
        else
          authenticate_user!
          authorize! :show, InternshipApplication
        end
      end


      def school_details
        authorize! :index, InternshipApplication
        @school = @internship_application.student.school
        @school_presenter = @school.presenter
      end

      private

      def fetch_user_internship_applications
        InternshipApplications::WeeklyFramed.where(
          internship_offer_id: current_user.internship_offers.ids
        ).where(aasm_state: valid_states) # not drafted
      end

      def fetch_internship_application
        @internship_application = InternshipApplication.find(params[:id])
      end

      def filter_by_week_or_application_date(internship_offer, params_order)
        includings = %i[ week
                         internship_offer
                         rich_text_motivation
                         internship_agreement
                         rich_text_rejected_message
                         rich_text_canceled_by_employer_message ]
        student_includings = %i[ school
                                 rich_text_resume_languages
                                 rich_text_resume_languages
                                 rich_text_resume_other ]
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

      def extra_message
        extra_message_text = 'Vous pouvez renseigner la convention dès maintenant.'
        extra_message_condition = @internship_application.approved? &&
                                  can?(:edit, @internship_application.internship_agreement)
        extra_message_condition ? extra_message_text : ''
      end

      def find_internship_offer
        @internship_offer = InternshipOffer.find(params[:internship_offer_id])
      end
    end
  end
end
