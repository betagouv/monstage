# frozen_string_literal: true

require 'test_helper'

module Dashboard
  module Schools
    class InternshipApplicationsTest < ActionDispatch::IntegrationTest
      include Devise::Test::IntegrationHelpers

      setup do
        @school = create(:school, :with_school_manager)
        @params = {
          support_ticket: {
            subject: '[Demande de stage à distance]',
            user_id: @school.school_manager.id,
            webinar: 1,
            message: 'Je voudrais des stages à distance'
          }
        }
        sign_in(@school.school_manager)
      end

      #
      # update by group
      #
      test 'POST support ticket redirects to after_login_path when parameters are compliant' do
        assert SupportTicket.new(@params[:support_ticket]).valid?
        assert_enqueued_with(job: CreateSupportTicketJob) do
          post dashboard_school_support_tickets_path(@school, params: @params)
        end
        assert_redirected_to dashboard_school_class_rooms_path(@school)
      end

      test 'POST support ticket redirects to new if parameters are not compliant' do
        @params[:support_ticket][:webinar] = 0
        @params[:support_ticket][:face_to_face] = 0
        refute SupportTicket.new(@params[:support_ticket]).valid?
        post dashboard_school_support_tickets_path(@school, params: @params)
        assert_match /input type=\"submit\" name=\"commit\" value=\"Je souhaite me faire accompagner par une association\"/, response.body
      end
    end
  end
end
