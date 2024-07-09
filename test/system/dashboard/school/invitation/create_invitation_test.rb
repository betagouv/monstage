require 'application_system_test_case'

module Dashboard
  class SchoolInvitationCreateInvitationTest < ApplicationSystemTestCase
    include Devise::Test::IntegrationHelpers

    test 'factory' do
      school = create(:school, :with_weeks, :with_school_manager)
      invitation = create(:invitation, user_id: school.school_manager.id)
      assert_equal 1, Invitation.all.count
    end

    test 'school manager can invite one of his teacher' do
      school = create(:school)
      school_manager = create(:school_manager, school: school)
      invitation = create(:invitation, user_id: school_manager.id)
      assert_equal 1, Invitation.all.count
      assert_equal school_manager, invitation.author

      sign_in(school_manager)
      visit dashboard_school_users_path(school_id: school.id)
      assert_difference 'Invitation.count' do
        click_link("Inviter un membre de l'équipe")
        fill_in('Nom', with: 'Picasso')
        fill_in('Prénom', with: 'Pablo')
        fill_in('Adresse électronique', with: 'pablo@ac-paris.fr')
        select('Professeur', from: 'Fonction')
        click_button("Inviter un membre de l'équipe")
      end
      assert_equal 2, all('button[aria-label="Renvoyer l\'invitation"]').count

      click_link("Inviter un membre de l'équipe")

      find('table tbody tr td', text: 'Pablo')
    end

    test 'school manager fails gracefully when inviting one of his teacher with the wrong email' do
      school = create(:school)
      school_manager = create(:school_manager, school: school)
      invitation = create(:invitation, user_id: school_manager.id)
      assert_equal 1, Invitation.all.count
      assert_equal school_manager, invitation.author

      sign_in(school_manager)
      visit dashboard_school_users_path(school_id: school.id)
      assert_no_difference 'Invitation.count' do
        click_link("Inviter un membre de l'équipe")
        fill_in('Nom', with: 'Picasso')
        fill_in('Prénom', with: 'Pablo')
        fill_in('Adresse électronique', with: 'pablo@gmail.com')
        select('Professeur', from: 'Fonction')
        click_button("Inviter un membre de l'équipe")
      end
      find("p#text-input-error-desc-error-email",text: "Email : l'adresse email utilisée doit être officielle.<br>ex: xxxx@ac-academie.fr")
    end

    test 'school manager fails gracefully when inviting one of his teacher with no function' do
      school = create(:school)
      school_manager = create(:school_manager, school: school)
      invitation = create(:invitation, user_id: school_manager.id)
      assert_equal 1, Invitation.all.count
      assert_equal school_manager, invitation.author

      sign_in(school_manager)
      visit dashboard_school_users_path(school_id: school.id)
      assert_no_difference 'Invitation.count' do
        click_link("Inviter un membre de l'équipe")
        fill_in('Nom', with: 'Picasso')
        fill_in('Prénom', with: 'Pablo')
        fill_in('Adresse électronique', with: 'pablo@ac-paris.fr')
        click_button("Inviter un membre de l'équipe")
      end
      find("#select-error-desc-error-role",text: "Fonction : doit être rempli(e)")
    end

    test 'school manager can resend the invitation' do
      school = create(:school)
      school_manager = create(:school_manager, school: school)
      invitation = create(:invitation, user_id: school_manager.id)
      assert_equal 1, Invitation.all.count
      assert_equal school_manager, invitation.author

      sign_in(school_manager)
      visit dashboard_school_users_path(school_id: school.id)
      accept_confirm do
        find('button[aria-label="Renvoyer l\'invitation"]').click
      end
      find('span#alert-text', text: "Votre invitation a été renvoyée")
    end

    test 'school manager can delete an invitation' do
      school = create(:school)
      school_manager = create(:school_manager, school: school)
      invitation = create(:invitation, user_id: school_manager.id)

      sign_in(school_manager)
      visit dashboard_school_users_path(school_id: school.id)
      assert_changes('Invitation.count', from: 1, to: 0 ) do
        find('button[aria-label="Supprimer l\'invitation"]')
        accept_confirm do
          find('button[aria-label="Supprimer l\'invitation"]').click
        end
        find( 'span#alert-text', text: "L'invitation a bien été supprimée")
      end
    end
  end
end
