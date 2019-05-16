require 'test_helper'

module InternshipApplications
  class ShowTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    test "GET #show renders preview for student owning internship_application" do
      internship_offer = create(:internship_offer)
      internship_application = create(:internship_application, :drafted, internship_offer: internship_offer)
      sign_in(internship_application.student)
      get internship_offer_internship_application_path(internship_offer,
                                                       internship_application)
      assert_response :success
      assert_select "a.btn-warning[href=\"#{internship_offer_internship_application_path(internship_offer, internship_application, transition: :submit!)}\"]"
      assert_select "a.btn-warning[data-method=patch]"
    end

    test "GET #show not owning internship_application is forbidden" do
      internship_offer = create(:internship_offer)
      internship_application = create(:internship_application, :drafted, internship_offer: internship_offer)
      sign_in(create(:student))
      get internship_offer_internship_application_path(internship_offer,
                                                       internship_application)
      assert_response :redirect
    end
  end
end
