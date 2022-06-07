# frozen_string_literal: true

require 'test_helper'

module Dashboard

  class InternshipApplicationsTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    # ===================================
    # Get rid of this file on 12/12/2022
    # ===================================
    # test 'As SchoolManager POST support ticket redirects to after_login_path when parameters are compliant' do
    #   school = create(:school, :with_school_manager)
    #   sign_in(school.school_manager)
    #   assert_enqueued_with(job: SupportTicketJobs::SchoolManager) do
    #     post(dashboard_support_tickets_path,
    #          params: {
    #            support_ticket: {
    #             webinar: 1,
    #             class_rooms_quantity: 2,
    #             students_quantity: 20,
    #             week_ids: [2048]
    #           }
    #         })
    #   end
    #   assert_redirected_to school.school_manager.custom_dashboard_path
    # end

    # test 'As SchoolManager POST support ticket redirects to new if mode parameters are not compliant' do
    #   school = create(:school, :with_school_manager)
    #   sign_in(school.school_manager)
    #   assert_no_enqueued_jobs(only: SupportTicketJobs::SchoolManager) do
    #     post(dashboard_support_tickets_path,
    #          params: {
    #           support_ticket: {
    #             webinar: 0,
    #             face_to_face: 0,
    #             digital_week: 0,
    #             class_rooms_quantity: 'bad quantity',
    #             students_quantity: 'bad quantity',
    #             week_ids: [2048]
    #           }
    #     })
    #     assert_response :bad_request
    #   end
    # end

    # test 'As Employer POST support ticket redirects to after_login_path when parameters are compliant' do
    #   sign_in(create(:employer))
    #   assert_enqueued_with(job: SupportTicketJobs::Employer) do
    #     post(dashboard_support_tickets_path,
    #          params: {
    #           support_ticket: {
    #             webinar: 1,
    #             speechers_quantity: 2,
    #             business_lines_quantity: 1,
    #             paqte: 1,
    #             week_ids: [2048]
    #           }
    #         })
    #   end
    #   assert_redirected_to dashboard_internship_offers_path
    # end

    # test 'As Employer POST support ticket redirects to new if mode parameters are not compliant' do
    #   sign_in(create(:employer))
    #   assert_no_enqueued_jobs(only: SupportTicketJobs::Employer) do
    #     post(dashboard_support_tickets_path,
    #          params: {
    #           support_ticket: {
    #             webinar: 1,
    #             speechers_quantity: 'bad speechers_quantity',
    #             business_lines_quantity: 'bad business_lines_quantity',
    #             paqte: 1,
    #             week_ids: [2048]
    #           }
    #         })
    #     assert_response :bad_request
    #   end
    # end
  end
end
