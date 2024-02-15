require "test_helper"

class TeamMemberInvitationControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'factory team_member_invitation is valid' do
    assert build(:team_member_invitation).valid?
  end

  # -------Invitations

  test "add team member" do
    employer_1 = create(:employer)
    employer_2 = create(:employer)
    sign_in employer_1
    get new_dashboard_team_member_invitation_path
    assert_response :success
    assert_difference "TeamMemberInvitation.count", 1 do
      post dashboard_team_member_invitations_path,
           params: { team_member_invitation: { invitation_email: employer_2.email } }
    end
    assert_redirected_to dashboard_team_member_invitations_path
    assert_equal "Membre d'équipe invité avec succès", flash[:success]
    assert_equal employer_1.id, TeamMemberInvitation.first.inviter_id
    # employer_2 not confirmed yet
    refute_equal employer_2.id, TeamMemberInvitation.first.member_id
  end

  test "add team member when not created yet" do
    employer_1 = create(:employer)
    employer_2 = build(:employer)
    sign_in employer_1
    get new_dashboard_team_member_invitation_path
    assert_response :success
    assert_difference "TeamMemberInvitation.count", 1 do
      post dashboard_team_member_invitations_path,
           params: { team_member_invitation: { invitation_email: employer_2.email } }
    end
    assert_redirected_to dashboard_team_member_invitations_path
    assert_equal "Membre d'équipe invité avec succès", flash[:success]
  end

  test "add team member that is already invited" do
    employer_1 = create(:employer)
    employer_2 = create(:employer)
    team_member_invitation = create :team_member_invitation,
                                    inviter_id: employer_1.id,
                                    invitation_email: employer_2.email
    refute employer_1.team.alive?
    sign_in employer_1
    get new_dashboard_team_member_invitation_path
    assert_response :success
    assert_difference "TeamMemberInvitation.count", 0 do
      post dashboard_team_member_invitations_path,
           params: { team_member_invitation: { invitation_email: employer_2.email } }
    end
    assert_redirected_to dashboard_team_member_invitations_path
    assert_equal "Ce collaborateur est déjà invité", flash[:warning]
  end

  test "add team member that is already a member of another team" do
    employer_1 = create(:employer)
    employer_2 = create(:employer)
    employer_3 = create(:employer)
    create(:team_member_invitation, :accepted_invitation, inviter: employer_3, member: employer_2)
    sign_in employer_1
    get new_dashboard_team_member_invitation_path
    assert_response :success
    assert_difference "TeamMemberInvitation.count", 0 do
      post dashboard_team_member_invitations_path,
           params: { team_member_invitation: { invitation_email: employer_2.email } }
    end
    assert_redirected_to dashboard_team_member_invitations_path
    assert_equal "Ce collaborateur fait déjà partie d’une équipe sur mon stage de troisième. Il ne pourra pas rejoindre votre équipe", flash[:alert]
  end

  # ------- Accept/refuse
    # ------- Accept
  test "invitation accepted" do
    employer_1 = create(:employer)
    employer_2 = create(:employer)
    team_member_invitation = create(:team_member_invitation,
                         inviter: employer_1,
                         member: employer_2,
                         invitation_email: employer_2.email)
    sign_in employer_2
    get new_dashboard_team_member_invitation_path
    assert_response :success
    assert_difference "TeamMemberInvitation.count", 1 do
      patch join_dashboard_team_member_invitation_path( id: team_member_invitation.id),
            params: { id: team_member_invitation.id, commit: "Oui" }
    end
    assert_redirected_to dashboard_team_member_invitations_path
    assert_equal team_member_invitation.reload.aasm_state, "accepted_invitation"
  end

  test 'when two employers of different team invite a third one, ignored invitation is refused' do
    employer_1 = create(:employer)
    employer_2 = create(:employer)
    employer_3 = create(:employer)
    team_member_1 = create(:team_member_invitation,
                           inviter: employer_1,
                           member: employer_3,
                           invitation_email: employer_3.email)
    team_member_2 = create(:team_member_invitation,
                           inviter: employer_2,
                           member: employer_3,
                           invitation_email: employer_3.email)
    sign_in employer_3
    get new_dashboard_team_member_invitation_path
    assert_response :success
    assert_difference "TeamMemberInvitation.count", 1 do
      patch join_dashboard_team_member_invitation_path( id: team_member_1.id),
            params: { id: team_member_1.id, commit: "Oui" }
    end
    assert_redirected_to dashboard_team_member_invitations_path
    assert_equal "accepted_invitation", team_member_1.reload.aasm_state
    assert_equal "refused_invitation", team_member_2.reload.aasm_state
  end

  test 'when two employers of different teams invite each other, ignored invitation is deleted' do
    employer_1 = create(:employer)
    employer_2 = create(:employer)
    team_member_1 = create(:team_member_invitation,
                           inviter: employer_1,
                           member: employer_2,
                           invitation_email: employer_2.email)
    team_member_2 = create(:team_member_invitation,
                           inviter: employer_2,
                           member: employer_1,
                           invitation_email: employer_1.email)
    sign_in employer_2
    get new_dashboard_team_member_invitation_path
    assert_response :success
    assert_no_difference "TeamMemberInvitation.count" do
      patch join_dashboard_team_member_invitation_path(id: team_member_1.id),
            params: { id: team_member_1.id, commit: "Oui" }
    end
    assert_redirected_to dashboard_team_member_invitations_path
    assert_equal team_member_1.reload.aasm_state, "accepted_invitation"
    assert_nil TeamMemberInvitation.find_by(id: team_member_2.id)
  end

  test "when an employer of the team invites a user that has accepted " \
       "invitation in between, it gets a special flash message telling him" \
       " it is already accepted" do
    employer_1 = create(:employer)
    employer_2 = create(:employer)
    employer_3 = create(:employer)
    team_member_1 = create(:team_member_invitation,
                           inviter: employer_1,
                           member: employer_3,
                           invitation_email: employer_3.email)
    team_member_2 = create(:team_member_invitation,
                           inviter: employer_2,
                           member: employer_3,
                           invitation_email: employer_3.email)
    sign_in employer_3
    TeamMemberInvitation.where(member: employer_3, inviter: employer_1)
                        .first
                        .accept_invitation!
    get new_dashboard_team_member_invitation_path
    assert_response :success
      patch join_dashboard_team_member_invitation_path( id: team_member_1.id),
            params: { id: team_member_2.id, commit: "Oui" }
    assert_redirected_to dashboard_team_member_invitations_path
    assert_equal "accepted_invitation", team_member_1.reload.aasm_state
    assert_equal "refused_invitation", team_member_2.reload.aasm_state
    assert_equal "L'invitation a déjà été acceptée", flash[:warning]
  end

    # ------- Refuse
  test "invitation refused" do
    employer_1 = create(:employer)
    employer_2 = create(:employer)
    team_member_invitation = create(:team_member_invitation, inviter: employer_1, member: employer_2, invitation_email: employer_2.email)
    sign_in employer_1
    get new_dashboard_team_member_invitation_path
    assert_response :success
    assert_difference "TeamMemberInvitation.count", 0 do
       patch join_dashboard_team_member_invitation_path( id: team_member_invitation.id),
           params: { id: team_member_invitation.id, commit: "Non"}
    end
    assert_redirected_to dashboard_team_member_invitations_path
    assert_equal team_member_invitation.reload.aasm_state, "refused_invitation"
  end
  # ------- END : Accept/refuse ------------
  test "delete team member with 2 people in team" do
    employer_1 = create(:employer)
    employer_2 = create(:employer)
    employer_3 = create(:employer)
    create(:team_member_invitation,
           :accepted_invitation,
           inviter: employer_1,
           member: employer_2,
           invitation_email: employer_2.email)
    team_member_invitation = create(:team_member_invitation,
           :accepted_invitation,
           inviter: employer_1,
           member: employer_1,
           invitation_email: employer_2.email)
    # Unused context
    create(:team_member_invitation,
           inviter: employer_1,
           member: nil,
           invitation_email: employer_3.email)

    assert_equal 3, TeamMemberInvitation.count
    assert_equal 2, TeamMemberInvitation.accepted_invitation.count
    assert_equal 2, TeamMemberInvitation.pluck(:member_id).compact.uniq.count
    sign_in employer_2
    get new_dashboard_team_member_invitation_path
    assert_response :success
    assert_difference "TeamMemberInvitation.count", -2 do
      delete dashboard_team_member_invitation_path(team_member_invitation)
    end
    assert_redirected_to dashboard_team_member_invitations_path
    assert_equal "Membre d'équipe supprimé avec succès. Votre équipe a été dissoute", flash[:success]
  end

  test "delete team member with 3 people in team" do
    employer_1 = create(:employer)
    employer_2 = create(:employer)
    employer_3 = create(:employer)
    create(:team_member_invitation,
           :accepted_invitation,
           inviter: employer_1,
           member: employer_2,
           invitation_email: employer_2.email)
    team_member_invitation = create(:team_member_invitation,
           :accepted_invitation,
           inviter: employer_1,
           member: employer_1,
           invitation_email: employer_2.email)
    create(:team_member_invitation,
           :accepted_invitation, # team with 3 people
           inviter: employer_1,
           member: employer_3,
           invitation_email: employer_3.email)

    sign_in employer_2
    get new_dashboard_team_member_invitation_path
    assert_response :success
    assert_difference "TeamMemberInvitation.count", -1 do
      delete dashboard_team_member_invitation_path(team_member_invitation)
    end
    assert_redirected_to dashboard_team_member_invitations_path
    assert_equal "Membre d'équipe supprimé avec succès.", flash[:success]
  end
end
