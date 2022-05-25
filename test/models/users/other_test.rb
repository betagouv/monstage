# frozen_string_literal: true

require 'test_helper'
module Users
  class OthersTest < ActiveSupport::TestCase
    setup do
      @url_helpers = Rails.application.routes.url_helpers
    end

    test 'creation fails ohter requires an .ac ending mail' do
      other = Users::SchoolManagement.new(
        role: :other,
        email: 'other@etablissement.com',
        school: create(:school)
      )

      assert other.invalid?
      assert_not_empty other.errors[:email]
    end

    test 'creation succeed' do
      school = build(:school, :with_school_manager)
      other = Users::SchoolManagement.new(
        role: :other,
        email: "jeanne@#{school.email_domain_name}",
        password: 'tototo',
        password_confirmation: 'tototo',
        first_name: 'Jeanne',
        last_name: 'CPE',
        school: school,
        accept_terms: true
      )

      assert other.valid?
    end

  end
end
