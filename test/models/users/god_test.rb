require 'test_helper'
module Users
  class GodTest < ActiveSupport::TestCase
     test 'god.after_sign_in_path redirects to dashboard_schools' do
      god = build(:god)
      assert_equal(god.after_sign_in_path,
                   Rails.application.routes.url_helpers.dashboard_schools_path)
    end
  end
end
