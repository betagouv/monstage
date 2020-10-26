# frozen_string_literal: true

require 'application_system_test_case'

class InternshipApplicationStudentFlowTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers

  test 'choose seearch' do
    visit root_path

    # active nav/tab is presential
    find("#nav-presential.active")
    find("#nav-presential-tab.active")

    # inactive is remote
    find("#nav-remote", visible: false)
    find("#nav-remote-tab:not(.active)")

    # switch tab
    find("#nav-remote-tab:not(.active)").click

    # inactive is now presential
    find("#nav-presential-tab:not(.active)")
    find("#nav-presential", visible: false)

    # active is now remote
    find("#nav-remote-tab.active")
    find("#nav-remote.active")
  end
end
