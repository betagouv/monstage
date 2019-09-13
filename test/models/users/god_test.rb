# frozen_string_literal: true

require 'test_helper'
module Users
  class GodTest < ActiveSupport::TestCase
    test 'god.after_sign_in_path redirects to rails admin' do
      god = build(:god)
      assert_equal(god.after_sign_in_path,
                   Rails.application.routes.url_helpers.rails_admin_path)
    end
  end
end
