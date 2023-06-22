require 'application_system_test_case'

module Dashboard
  class InvitationTest < ApplicationSystemTestCase
    include Devise::Test::IntegrationHelpers
    test 'resend' do
      school = create(:school)
      school_manager = create(:school_manager, school: school)
      invitation = create(:invitation, user_id: school_manager.id)
      assert_equal 1, Invitation.all.count
      assert_equal school_manager, invitation.author

      sign_in(school_manager)
      visit dashboard_school_users_path(school_id: school.id)
      assert_difference 'Invitation.count' do
        accept_confirm do
          find('button[aria-label="Renvoyer l\'invitation"]').click
        end
        click_link("Inviter un membre de l'équipe")
        fill_in('Nom', with: 'Picasso')
        fill_in('Prénom', with: 'Pablo')
        fill_in('Adresse électronique', with: 'pablo@ac-paris.fr')
        select('Professeur', from: 'Fonction')
        click_button("Inviter un membre de l'équipe")
        assert_equal 2, all('button[aria-label="Renvoyer l\'invitation"]').count
      end
    end
  end
end
