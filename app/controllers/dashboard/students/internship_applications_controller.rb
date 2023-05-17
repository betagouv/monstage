# frozen_string_literal: true

module Dashboard
  module Students
    class InternshipApplicationsController < ApplicationController
      before_action :authenticate_user!, except: %i[direct_to_internship_application]
      before_action :set_current_student
      before_action :set_internship_application, except: %i[index]

      def index
        authorize! :dashboard_index, @current_student
        @internship_applications = @current_student.internship_applications
                                                   .includes(:internship_offer, :student)
                                                   .order_by_aasm_state
      end

      def show
        authorize! :dashboard_show, @internship_application
      end

      def resend_application
        if @internship_application.max_dunning_letter_count_reached?
          redirect_to dashboard_students_internship_applications_path(@current_student),
                      alert: "Vous avez atteint le nombre maximum de relances pour cette candidature"
        else
          increase_dunning_letter_count
          EmployerMailer.resend_internship_application_submitted_email(internship_application: @internship_application).deliver_now
        end
      end

      def direct_to_internship_application
        internship_application_path = dashboard_internship_offer_internship_application_path(
          internship_offer_id: @internship_application.internship_offer.id,
          id: @internship_application.id
        )
        redirect_to internship_application_path unless params[:sgid]

        student = GlobalID::Locator.locate_signed(params[:sgid])
        magic_link_tracker = 1
        if student&.student? && student.id == @current_student.id
          sign_in(student)
        else
          magic_link_tracker = 2
        end
        @internship_application.update(magic_link_tracker: magic_link_tracker)
        redirect_to internship_application_path
      end

      private

      def set_current_student
        @current_student = ::Users::Student.find(params[:student_id])
      end

      def set_internship_application
        @internship_application = @current_student.internship_applications.find(params[:id])
      end

      def increase_dunning_letter_count
        current_count = @internship_application.dunning_letter_count
        @internship_application.update(dunning_letter_count: current_count + 1)
      end
    end
  end
end
