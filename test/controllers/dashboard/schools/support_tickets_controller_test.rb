# frozen_string_literal: true

require 'test_helper'

module Dashboard
  module Schools
    class InternshipApplicationsTest < ActionDispatch::IntegrationTest
      include Devise::Test::IntegrationHelpers

      setup do
        @school = create(:school, :with_school_manager)
        @params = {
          support_tickets_school_manager: {
            subject: '[Demande de stage à distance]',
            user_id: @school.school_manager.id,
            webinar: 1,
            class_rooms_quantity: 2,
            students_quantity: 20,
            week_ids: [2048]
          }
        }
        sign_in(@school.school_manager)
      end

      def submit_fails_and_renders_new(params)
        refute SupportTickets::SchoolManager.new(params[:support_tickets_school_manager]).valid?
        post dashboard_school_support_tickets_path(@school, params: params)
        assert_match /input type=\"submit\" name=\"commit\" value=\"Envoyer la demande\"/, response.body
      end

      test 'POST support ticket redirects to after_login_path when parameters are compliant' do
        assert SupportTickets::SchoolManager.new(@params[:support_tickets_school_manager]).valid?
        assert_enqueued_with(job: SupportTicketJobs::SchoolManager) do
          post dashboard_school_support_tickets_path(@school, params: @params)
        end
        assert_redirected_to dashboard_school_class_rooms_path(@school)
      end

      test 'POST support ticket redirects to new if mode parameters are not compliant' do
        @params[:support_tickets_school_manager][:webinar] = 0
        @params[:support_tickets_school_manager][:face_to_face] = 0
        @params[:support_tickets_school_manager][:digital_week] = 0
        submit_fails_and_renders_new(@params)
      end

      test 'POST support ticket redirects to new if parameter week_ids is not compliant' do
        @params[:support_tickets_school_manager][:week_ids] = []
        submit_fails_and_renders_new(@params)
      end

      test 'POST support ticket redirects to new if students_quantity parameter is not compliant' do
        @params[:support_tickets_school_manager][:students_quantity] = 'string'
        submit_fails_and_renders_new(@params)
      end

      test 'POST support ticket redirects to new if class_rooms_quantity parameters is not compliant' do
        @params[:support_tickets_school_manager][:class_rooms_quantity] = ''
        submit_fails_and_renders_new(@params)
      end
    end
  end
end
