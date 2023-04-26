# frozen_string_literal: true

require 'test_helper'
module Users
  class TeacherTest < ActiveSupport::TestCase
    setup do
      @url_helpers = Rails.application.routes.url_helpers
    end

    test 'creation fails teacher requires an .ac ending mail' do
      teacher = Users::SchoolManagement.new(
        role: :teacher,
        email: 'teacher@etablissement.com',
        school: create(:school)
      )

      assert teacher.invalid?
      assert_not_empty teacher.errors[:email]
    end

    test 'creation succeed' do
      school = build(:school, :with_school_manager)
      teacher = Users::SchoolManagement.new(
        role: :teacher,
        email: "jeanne@#{school.email_domain_name}",
        password: 'tototo',
        first_name: 'Jeanne',
        last_name: 'Proffe',
        school: school,
        accept_terms: true
      )

      assert teacher.valid?
    end

  end
end
