# frozen_string_literal: true

require 'test_helper'

module Dashboard
  module InternshipOffers
    class SupportTicketsControllerTest < ActionDispatch::IntegrationTest
      include Devise::Test::IntegrationHelpers

      setup do
        @employer = create(:employer)
        @params = {
          support_tickets_employer: {
            subject: '[Proposition de stage à distance]',
            user_id: @employer.id,
            webinar: 1,
            speechers_quantity: 2,
            business_lines_quantity: 1,
            paqte: 1,
            week_ids: [2048]
          }
        }
        sign_in(@employer)
      end

      def submit_fails_and_renders_new(params)
        refute SupportTickets::Employer.new(params[:support_tickets_employer]).valid?
        post dashboard_support_tickets_path(params: params)
        assert_match /input type=\"submit\" name=\"commit\" value=\"Envoyer la demande\"/, response.body
      end

      test 'POST support ticket redirects to after_login_path when parameters are compliant' do
        assert SupportTickets::Employer.new(@params[:support_tickets_employer]).valid?
        assert_enqueued_with(job: SupportTicketJobs::Employer) do
          post dashboard_support_tickets_path(params: @params)
        end
        assert_redirected_to dashboard_internship_offers_path
      end

      test 'POST support ticket redirects to new if mode parameters are not compliant' do
        @params[:support_tickets_employer][:webinar] = 0
        @params[:support_tickets_employer][:face_to_face] = 0
        @params[:support_tickets_employer][:digital_week] = 0
        submit_fails_and_renders_new(@params)
      end

      test 'POST support ticket redirects to new if parameter week_ids is not compliant' do
        @params[:support_tickets_employer][:week_ids] = []
        submit_fails_and_renders_new(@params)
      end

      test 'POST support ticket redirects to new if students_quantity parameter is not compliant' do
        @params[:support_tickets_employer][:speechers_quantity] = 'string'
        submit_fails_and_renders_new(@params)
      end

      test 'POST support ticket redirects to new if class_rooms_quantity parameters is not compliant' do
        @params[:support_tickets_employer][:business_lines_quantity] = ''
        submit_fails_and_renders_new(@params)
      end
    end
  end
end
