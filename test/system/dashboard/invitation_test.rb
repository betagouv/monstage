require 'application_system_test_case'

module Dashboard
  class InvitationTest < ApplicationSystemTestCase
    include Devise::Test::IntegrationHelpers
    test 'resend' do
      school = create(:school)
      school_manager = create(:school_manager, school: school)
      # invitation = create(:invitation, user_id: school_manager.id)

      sign_in(school_manager)
      visit dashboard_school_users_path(school_id: school.id)
      click_link("Inviter un membre de l'équipe")

      find('button[aria-label="Renvoyer l\'invitation"]').click
    end
  end
end
