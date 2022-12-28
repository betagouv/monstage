# frozen_string_literal: true

require 'application_system_test_case'

class SchoolsTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers
  include SchoolFormFiller

  test 'can create School' do
    god = create(:god)
    sign_in(god)
    # assert_difference 'School.count' do
    #   visit new_school_path
    #   fill_in_school_form
    #   click_on "Créer l'établissement"
    # end
  end
end