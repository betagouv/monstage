module Dashboard
  module Students
    class InternshipApplicationsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_current_student
      before_action :set_internship_application, only: [:show]

      def index
        authorize! :dashboard_index, @current_student
      end

      def show
        authorize! :dashboard_show, @internship_application
      end

      private
      def set_current_student
        @current_student = Users::Student.find(params[:student_id])
      end

      def set_internship_application
        @internship_application = @current_student.internship_applications
                                                   .find(params[:id])
      end
    end
  end
end
