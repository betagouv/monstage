require 'application_system_test_case'
module Dashboard::TeamMemberInvitations
  class InvitationAndMembershipTest < ApplicationSystemTestCase
    include Devise::Test::IntegrationHelpers
    include TeamAndAreasHelper

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
      refute employer_1.team.alive?
      refute employer_2.team.alive?
      assert_equal 1, employer_1.team_member_invitations.count
    end

    test 'when two employers are in the same team, ' \
         'they cannot place an invitation to the same third employer' do
      employer_1 = create(:employer)
      employer_2 = create(:employer)
      create_team(employer_1, employer_2)
      employer_3 = create(:employer)

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

     test 'when two employers are in the same team on a single area, ' \
         'they can manage internship_applications of the team' do
      employer_1 = create(:employer)
      employer_2 = create(:employer)
      internship_offer = create_internship_offer_visible_by_two(employer_1, employer_2)
      internship_application_1 = create(:weekly_internship_application, :submitted, internship_offer: internship_offer)

      sign_in(employer_2)
      visit dashboard_candidatures_path
      find('p.fr-badge--info', text: "nouveau".upcase)
      find('a[title="Répondre à la candidature"]', text: "Répondre").click
      click_button("Accepter")
      click_button("Confirmer")
      find('p.fr-badge--info', text: "en attente de réponse".upcase)
    end

    test 'when two employers are in the same team on a single area, ' \
         'they can manage internship_agreements of the team' do
      employer_1 = create(:employer)
      employer_2 = create(:employer)
      internship_offer = create_internship_offer_visible_by_two(employer_1, employer_2)
      internship_application_1 = create(:weekly_internship_application, :approved, internship_offer: internship_offer)
      assert InternshipAgreement.count == 1
      student = internship_application_1.student

      sign_in(employer_2)
      visit dashboard_internship_agreements_path
      find('a.button-component-cta-button', text: "Remplir ma convention").click
      find('.h2[aria-level="1"][role="heading"]', text: "Édition de la convention de stage")
    end

    ## ============= Operators ===================

    test 'as operator, team member can invite a new team member' do
      operator_1 = create(:user_operator)
      sign_in(operator_1)
      operator_2 = create(:user_operator)
      visit dashboard_internship_agreements_path
      click_link 'équipe'.capitalize
      find('a', text: "Inviter un membre de l'équipe").click
      fill_in 'team_member_invitation[invitation_email]', with: operator_2.email
      click_on 'Inviter'
      assert_text "Membre d'équipe invité avec succès"
      assert_equal 0, operator_1.team.team_size
      assert_equal 0, operator_2.team.team_size
      assert_equal 1, operator_1.team_member_invitations.count
    end

    test 'when two user operators are in the same team, ' \
         'they cannot place an invitation to the same third employer' do
      user_operator_1 = create(:user_operator)
      user_operator_2 = create(:user_operator)
      create_team(user_operator_1, user_operator_2)
      user_operator_3 = create(:user_operator)

      sign_in(user_operator_1)
      visit dashboard_team_member_invitations_path
      click_link 'équipe'.capitalize
      find('a', text: "Inviter un membre de l'équipe").click
      fill_in 'team_member_invitation[invitation_email]', with: user_operator_3.email
      click_on 'Inviter'
      logout(user_operator_1)

      assert_equal 3, TeamMemberInvitation.count
      assert_equal 1, TeamMemberInvitation.with_pending_invitations.count
      pending_invitation = TeamMemberInvitation.with_pending_invitations.first
      assert_equal user_operator_1.id, pending_invitation.inviter_id
      assert_equal user_operator_3.email, pending_invitation.invitation_email

      sign_in(user_operator_2)
      visit dashboard_team_member_invitations_path
      click_link 'équipe'.capitalize
      find('a', text: "Inviter un membre de l'équipe").click
      fill_in 'team_member_invitation[invitation_email]', with: user_operator_3.email
      click_on 'Inviter'
      assert_text "Ce collaborateur est déjà invité"
    end

    test 'a user_operator can accept an invitation to join a team' do
      user_operator_1 = create(:user_operator)
      user_operator_2 = create(:user_operator)
      assert_equal 0, user_operator_1.team.team_size
      assert_equal 0, user_operator_2.team.team_size
      assert_equal 2, InternshipOfferArea.count
      create :team_member_invitation,
             inviter_id: user_operator_1.id,
             invitation_email: user_operator_2.email
      sign_in(user_operator_2)
      visit user_operator_2.after_sign_in_path
      click_button 'Oui'
      assert_equal 2, all('span.fr-badge.fr-badge--no-icon.fr-badge--success', text: "INSCRIT").count
      assert_equal 2, user_operator_1.team.team_size
      assert_equal 2, user_operator_2.team.team_size
    end

    test 'an operator can refuse an invitation to join a team' do
      user_operator_1 = create(:user_operator)
      user_operator_2 = create(:user_operator)
      create :team_member_invitation,
             inviter_id: user_operator_1.id,
             invitation_email: user_operator_2.email

      sign_in(user_operator_2)
      visit user_operator_2.after_sign_in_path
      click_button 'Non'
      find('h1.fr-h3', text: "Collaborez facilement avec votre équipe")
      assert_equal 1, TeamMemberInvitation.refused_invitations.count
      assert_equal 0, all('span.fr-badge.fr-badge--no-icon.fr-badge--error', text: "refusée".upcase).count
      assert_equal 0, user_operator_1.team.team_size
      assert_equal 0, user_operator_2.team.team_size
      logout(user_operator_2)

      sign_in(user_operator_1)
      visit dashboard_team_member_invitations_path
      assert_equal 1, all('span.fr-badge.fr-badge--no-icon.fr-badge--error', text: "refusée".upcase).count
    end

     test 'when two user_operators are in the same team on a single area, ' \
          'they can manage internship_applications of the team' do
      user_operator_1 = create(:user_operator)
      user_operator_2 = create(:user_operator)
      internship_offer = create_internship_offer_visible_by_two(user_operator_1, user_operator_2)
      internship_application_1 = create(:weekly_internship_application, :submitted, internship_offer: internship_offer)

      sign_in(user_operator_2)
      visit dashboard_candidatures_path
      find('p.fr-badge--info', text: "nouveau".upcase)
      find('a[title="Répondre à la candidature"]', text: "Répondre").click
      click_button("Accepter")
      click_button("Confirmer")
      click_link("Candidatures")
      click_button("Acceptées")
      find('p.fr-badge--info', text: "en attente de réponse".upcase)
    end

    ## ============= statisticians ===================
    test 'as statistician, team member can invite a new team member' do
      statistician_1 = create(:statistician)
      sign_in(statistician_1)
      statistician_2 = create(:statistician)
      visit dashboard_internship_agreements_path
      click_link 'équipe'.capitalize
      find('a', text: "Inviter un membre de l'équipe").click
      fill_in 'team_member_invitation[invitation_email]', with: statistician_2.email
      click_on 'Inviter'
      assert_text "Membre d'équipe invité avec succès"
      assert_equal 0, statistician_1.team.team_size
      assert_equal 0, statistician_2.team.team_size
      collection = statistician_1.team_member_invitations
      assert_equal 1, collection.count
    end

    test 'when two statisticians are in the same team, ' \
         'they cannot place an invitation to the same third employer' do
      statistician_1 = create(:statistician)
      statistician_2 = create(:statistician)
      create_team(statistician_1, statistician_2)
      statistician_3 = create(:statistician)

      sign_in(statistician_1)
      visit dashboard_team_member_invitations_path
      click_link 'équipe'.capitalize
      find('a', text: "Inviter un membre de l'équipe").click
      fill_in 'team_member_invitation[invitation_email]', with: statistician_3.email
      click_on 'Inviter'
      logout(statistician_1)

      assert_equal 3, TeamMemberInvitation.count
      assert_equal 1, TeamMemberInvitation.with_pending_invitations.count
      pending_invitation = TeamMemberInvitation.with_pending_invitations.first
      assert_equal statistician_1.id, pending_invitation.inviter_id
      assert_equal statistician_3.email, pending_invitation.invitation_email

      sign_in(statistician_2)
      visit dashboard_team_member_invitations_path
      click_link 'équipe'.capitalize
      find('a', text: "Inviter un membre de l'équipe").click
      fill_in 'team_member_invitation[invitation_email]', with: statistician_3.email
      click_on 'Inviter'
      assert_text "Ce collaborateur est déjà invité"
    end

    test 'a statistician can accept an invitation to join a team' do
      statistician_1 = create(:statistician)
      statistician_2 = create(:statistician)
      create :team_member_invitation,
             inviter_id: statistician_1.id,
             invitation_email: statistician_2.email
      sign_in(statistician_2)
      visit statistician_2.after_sign_in_path
      click_button 'Oui'
      assert_equal 2, all('span.fr-badge.fr-badge--no-icon.fr-badge--success', text: "INSCRIT").count
      assert_equal 2, statistician_1.team.team_size
      assert_equal 2, statistician_2.team.team_size
    end

    test 'a statistician can refuse an invitation to join a team' do
      statistician_1 = create(:statistician)
      statistician_2 = create(:statistician)
      create :team_member_invitation,
             inviter_id: statistician_1.id,
             invitation_email: statistician_2.email

      sign_in(statistician_2)
      visit statistician_2.after_sign_in_path
      click_button 'Non'
      find('h1.fr-h3', text: "Collaborez facilement avec votre équipe")
      assert_equal 1, TeamMemberInvitation.refused_invitations.count
      assert_equal 0, all('span.fr-badge.fr-badge--no-icon.fr-badge--error', text: "refusée".upcase).count
      assert_equal 0, statistician_1.team.team_size
      assert_equal 0, statistician_2.team.team_size
      logout(statistician_2)

      sign_in(statistician_1)
      visit dashboard_team_member_invitations_path
      assert_equal 1, all('span.fr-badge.fr-badge--no-icon.fr-badge--error', text: "refusée".upcase).count
    end

    test 'when two statisticians are in the same team on a single area, ' \
          'they can manage internship_applications of the team' do
      statistician_1 = create(:statistician, agreement_signatorable: true)
      statistician_2 = create(:statistician, agreement_signatorable: true)
      internship_offer = create_internship_offer_visible_by_two(statistician_1, statistician_2)
      internship_application_1 = create(:weekly_internship_application, :submitted, internship_offer: internship_offer)
      assert statistician_2.team.team_size == 2

      sign_in(statistician_2)
      visit dashboard_candidatures_path
      find('p.fr-badge--info', text: "nouveau".upcase)
      find('a[title="Répondre à la candidature"]', text: "Répondre").click
      click_button("Accepter")
      click_button("Confirmer")
      click_link("Candidatures")
      click_button("Acceptées")
      find('p.fr-badge--info', text: "en attente de réponse".upcase)
    end

    test 'as statistician, when two statisticians are in the same team on a single area, ' \
          'they can manage internship_agreements of the team' do
      statistician_1 = create(:statistician, agreement_signatorable: true)
      statistician_2 = create(:statistician, agreement_signatorable: true)
      internship_offer = create_internship_offer_visible_by_two(statistician_1, statistician_2)
      internship_application_1 = create(:weekly_internship_application, :approved, internship_offer: internship_offer)
      assert InternshipAgreement.count == 1

      sign_in(statistician_2)
      visit dashboard_internship_agreements_path
      find('a.button-component-cta-button', text: "Remplir ma convention").click
      find('.h2[aria-level="1"][role="heading"]', text: "Édition de la convention de stage")
    end
  end
end
