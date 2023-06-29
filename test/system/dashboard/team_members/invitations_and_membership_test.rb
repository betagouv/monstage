require 'application_system_test_case'
module Dashboard::TeamMemberInvitations
  class InvitationAndMembershipTest < ApplicationSystemTestCase
    include Devise::Test::IntegrationHelpers

    test 'team member can invite a new team member' do
      employer_1 = create(:employer)
      sign_in(employer_1)
      employer_2 = create(:employer)
      visit dashboard_internship_agreements_path
      click_link 'équipe'.capitalize
      find('a', text: "Inviter un membre de l'équipe").click
      fill_in 'team_member_invitation[invitation_email]', with: employer_2.email
      click_on 'Inviter'
      assert_text "Membre d'équipe invité avec succès"
      assert_equal 0, employer_1.team.team_size
      assert_equal 0, employer_2.team.team_size
      assert_equal 1, employer_1.team_member_invitations.count
    end

    test 'when two employers are in the same team, ' \
         'they cannot place an invitation to the same third employer' do
      employer_1 = create(:employer)
      employer_2 = create(:employer)
      employer_3 = create(:employer)
      create :team_member_invitation,
             :accepted_invitation,
             inviter_id: employer_1.id,
             member_id: employer_2.id
      create :team_member_invitation,
             :accepted_invitation,
             inviter_id: employer_1.id,
             member_id: employer_1.id

      sign_in(employer_1)
      visit dashboard_team_member_invitations_path
      click_link 'équipe'.capitalize
      find('a', text: "Inviter un membre de l'équipe").click
      fill_in 'team_member_invitation[invitation_email]', with: employer_3.email
      click_on 'Inviter'
      logout(employer_1)

      assert_equal 3, TeamMemberInvitation.count
      assert_equal 1, TeamMemberInvitation.with_pending_invitations.count
      pending_invitation = TeamMemberInvitation.with_pending_invitations.first
      assert_equal employer_1.id, pending_invitation.inviter_id
      assert_equal employer_3.email, pending_invitation.invitation_email

      sign_in(employer_2)
      visit dashboard_team_member_invitations_path
      click_link 'équipe'.capitalize
      find('a', text: "Inviter un membre de l'équipe").click
      fill_in 'team_member_invitation[invitation_email]', with: employer_3.email
      click_on 'Inviter'
      assert_text "Ce collaborateur est déjà invité"
    end

    test 'a employer can accept an invitation to join a team' do
      employer_1 = create(:employer)
      employer_2 = create(:employer)
      create :team_member_invitation,
             inviter_id: employer_1.id,
             invitation_email: employer_2.email
      sign_in(employer_2)
      visit employer_2.after_sign_in_path
      click_button 'Oui'
      assert_equal 2, all('span.fr-badge.fr-badge--no-icon.fr-badge--success', text: "INSCRIT").count
      assert_equal 2, employer_1.team.team_size
      assert_equal 2, employer_2.team.team_size
    end

    test 'an employer can refuse an invitation to join a team' do
      employer_1 = create(:employer)
      employer_2 = create(:employer)
      create :team_member_invitation,
             inviter_id: employer_1.id,
             invitation_email: employer_2.email

      sign_in(employer_2)
      visit employer_2.after_sign_in_path
      click_button 'Non'
      find('h1.fr-h3', text: "Collaborez facilement avec votre équipe")
      assert_equal 1, TeamMemberInvitation.refused_invitations.count
      assert_equal 0, all('span.fr-badge.fr-badge--no-icon.fr-badge--error', text: "refusée".upcase).count
      assert_equal 0, employer_1.team.team_size
      assert_equal 0, employer_2.team.team_size
      logout(employer_2)

      sign_in(employer_1)
      visit dashboard_team_member_invitations_path
      assert_equal 1, all('span.fr-badge.fr-badge--no-icon.fr-badge--error', text: "refusée".upcase).count
    end

     test 'when two employers are in the same team, ' \
         'they can manage internship_applications of the team' do
      employer_1 = create(:employer)
      employer_2 = create(:employer)
      internship_offer = create(:weekly_internship_offer, employer: employer_1)
      internship_application_1 = create(:weekly_internship_application, :submitted, internship_offer: internship_offer)
      create :team_member_invitation,
             :accepted_invitation,
             inviter_id: employer_1.id,
             member_id: employer_2.id
      create :team_member_invitation,
             :accepted_invitation,
             inviter_id: employer_1.id,
             member_id: employer_1.id
      assert employer_2.team.team_size == 2

      sign_in(employer_2)
      visit dashboard_candidatures_path
      find('p.fr-badge--info', text: "nouveau".upcase)
      find('a[title="Répondre à la candidature"]', text: "Répondre").click
      click_button("Accepter")
      click_button("Confirmer")
      find('p.fr-badge--info', text: "en attente de réponse".upcase)
    end

    test 'when two employers are in the same team, ' \
         'they can manage internship_agreements of the team' do
      employer_1 = create(:employer)
      employer_2 = create(:employer)
      internship_offer = create(:weekly_internship_offer, employer: employer_1)
      internship_application_1 = create(:weekly_internship_application, :approved, internship_offer: internship_offer)
      assert InternshipAgreement.count == 1
      student = internship_application_1.student
      create :team_member_invitation,
             :accepted_invitation,
             inviter_id: employer_1.id,
             member_id: employer_2.id
      create :team_member_invitation,
             :accepted_invitation,
             inviter_id: employer_1.id,
             member_id: employer_1.id

      sign_in(employer_2)
      visit dashboard_internship_agreements_path
      find('a.button-component-cta-button', text: "Remplir ma convention").click
      find('.h2[aria-level="1"][role="heading"]', text: "Édition de la convention de stage")
    end
  end
end
