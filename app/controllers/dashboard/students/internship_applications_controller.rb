# frozen_string_literal: true

module Dashboard
  module Students
    class InternshipApplicationsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_current_student

      def index
        authorize! :dashboard_index, @current_student
        @internship_applications = @current_student.internship_applications
                                                   .includes(:internship_offer, :student)
                                                   .order_by_aasm_state
      end

      def show
        @internship_application = @current_student.internship_applications.find(params[:id])
        authorize! :dashboard_show, @internship_application
      end

      private

      def set_current_student
        @current_student = ::Users::Student.find(params[:student_id])
      end
    end
  end
end
