require 'test_helper'

class InternshipApplicationsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "POST #create internship application" do
    internship_offer = create(:internship_offer)
    student = create(:student)

    valid_params = { internship_application: { internship_offer_week_id: internship_offer.internship_offer_weeks.first.id,
                                               motivation: 'Je suis trop motivé wesh',
                                               user_id: student.id
                                             }}
    assert_difference('InternshipApplication.count', 1) do
      post(internship_offer_internship_applications_path(internship_offer), params: valid_params)
    end
    assert_redirected_to internship_offers_path

    created_internship_application = InternshipApplication.last
    assert_equal internship_offer.internship_offer_weeks.first.id, created_internship_application.internship_offer_week.id
    assert_equal 'Je suis trop motivé wesh', created_internship_application.motivation
    assert_equal student.id, created_internship_application.student.id
  end

  test "POST #create internship application failed" do
    internship_offer = create(:internship_offer)
    student = create(:student)

    valid_internship_application_params = { internship_offer_week_id: internship_offer.internship_offer_weeks.first.id,
                                               motivation: 'Je suis trop motivé wesh',
                                               user_id: student.id
                                             }

    assert_no_difference('InternshipApplication.count') do
      post(internship_offer_internship_applications_path(internship_offer),
           params: { internship_application: valid_internship_application_params.except(:motivation)})
    end
    assert_redirected_to internship_offer_path(internship_offer)

    assert_no_difference('InternshipApplication.count') do
      post(internship_offer_internship_applications_path(internship_offer),
           params: { internship_application: valid_internship_application_params.except(:internship_offer_week_id)})
    end
    assert_redirected_to internship_offer_path(internship_offer)

    assert_no_difference('InternshipApplication.count') do
      post(internship_offer_internship_applications_path(internship_offer),
           params: { internship_application: valid_internship_application_params.except(:user_id)})
    end
    assert_redirected_to internship_offer_path(internship_offer)
  end

  test "PATCH #update approve application" do
    internship_application = create(:internship_application)

    sign_in(internship_application.internship_offer.employer)

    patch(internship_offer_internship_application_path(internship_application.internship_offer, internship_application),
          params: { approve: true })

    assert_redirected_to internship_offer_path(internship_application.internship_offer)

    assert InternshipApplication.last.approved?
  end

  test "PATCH #update decline application" do
    internship_application = create(:internship_application)

    sign_in(internship_application.internship_offer.employer)

    patch(internship_offer_internship_application_path(internship_application.internship_offer, internship_application),
          params: { approve: false })

    assert_redirected_to internship_offer_path(internship_application.internship_offer)

    assert InternshipApplication.last.rejected?
  end
end
