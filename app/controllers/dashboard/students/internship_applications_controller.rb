# frozen_string_literal: true

module Dashboard
  module Students
    class InternshipApplicationsController < ApplicationController
      include ApplicationTransitable
      before_action :authenticate_user!, except: %i[show]
      before_action :set_current_student
      before_action :set_internship_application, except: %i[index]

      MAGIC_EXPIRATION_TIME = 3.days

      def index
        authorize! :dashboard_index, @current_student
        @internship_applications = @current_student.internship_applications
                                                   .includes(:internship_offer, :student)
                                                   .order_by_aasm_state_for_student
                                                   .order(created_at: :desc)
      end

      # 0 no magic link - status quo - default value
      # 1 magic link successfully clicked
      # 2 magic link clicked but expired
      def show
        if params[:sgid].present? && magic_fetch_student&.student? && magic_fetch_student.id == @current_student.id
          @internship_application.update(magic_link_tracker: 1)
          @internship_application_sgid= @internship_application.to_sgid(expires_in: MAGIC_EXPIRATION_TIME).to_s
          render 'dashboard/students/internship_applications/making_decisions' and return
        elsif params[:sgid].present?
          @internship_application.update(magic_link_tracker: 2)
          redirect_to(
            dashboard_students_internship_application_path(
                        student_id: @current_student.id,
                        uuid: @internship_application.uuid)
          ) and return
        else
           authenticate_user!
        end
        authorize! :dashboard_show, @internship_application
        @internship_offer = @internship_application.internship_offer
      end

      def edit
        authorize! :internship_application_edit, @internship_application
        @internship_offer = @internship_application.internship_offer
      end

      def resend_application
        if @internship_application.max_dunning_letter_count_reached?
          redirect_to dashboard_students_internship_applications_path(@current_student),
                      alert: "Vous avez atteint le nombre maximum de relances pour cette candidature"
        else
          increase_dunning_letter_count
          EmployerMailer.resend_internship_application_submitted_email(internship_application: @internship_application).deliver_now
          redirect_to dashboard_students_internship_application_path(student_id: @current_student.id, uuid: @internship_application.uuid),
                      notice: "Votre candidature a bien été renvoyée"
        end
      end

      private

      def magic_fetch_student
        GlobalID::Locator.locate_signed(params[:sgid])
      end

      def set_current_student
        @current_student = ::Users::Student.find(params[:student_id])
      end

      def set_internship_application
        @internship_application = @current_student.internship_applications.find_by(uuid: params[:uuid])
      end

      def increase_dunning_letter_count
        current_count = @internship_application.dunning_letter_count
        @internship_application.update(dunning_letter_count: current_count + 1)
      end
    end
  end
end
