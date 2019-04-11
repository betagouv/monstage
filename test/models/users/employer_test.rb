require 'test_helper'
module Users
  class EmployerTest < ActiveSupport::TestCase
    test 'employer.after_sign_in_path redirects to internship_offers_path' do
      employer = build(:employer)
      assert_equal(employer.after_sign_in_path,
                   Rails.application.routes.url_helpers.dashboard_internship_offers_path)
    end
  end
end
