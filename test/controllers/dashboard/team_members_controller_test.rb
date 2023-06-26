require "test_helper"

class TeamMemberControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'factory team_member is valid' do
    assert build(:team_member).valid?
  end

  # -------Invitations

  test "add team member" do
    employer_1 = create(:employer)
    employer_2 = create(:employer)
    sign_in employer_1
    get new_dashboard_team_member_path
    assert_response :success
    assert_difference "TeamMember.count", 1 do
      post dashboard_team_members_path,
           params: { team_member: { invitation_email: employer_2.email } }
    end
    assert_redirected_to dashboard_team_members_path
    assert_equal "Membre d'équipe invité avec succès", flash[:success]
    assert_equal employer_1.id, TeamMember.first.inviter_id
    # employer_2 not confirmed yet
    refute_equal employer_2.id, TeamMember.first.member_id
  end

  test "add team member when not created yet" do
    employer_1 = create(:employer)
    employer_2 = build(:employer)
    sign_in employer_1
    get new_dashboard_team_member_path
    assert_response :success
    assert_difference "TeamMember.count", 1 do
      post dashboard_team_members_path,
           params: { team_member: { invitation_email: employer_2.email } }
    end
    assert_redirected_to dashboard_team_members_path
    assert_equal "Membre d'équipe invité avec succès", flash[:success]
  end

  test "add team member that is already invited" do
    employer_1 = create(:employer)
    employer_2 = create(:employer)
    team_member = create :team_member,
                         inviter_id: employer_1.id,
                         invitation_email: employer_2.email
    assert employer_1.team.team_size.zero?
    sign_in employer_1
    get new_dashboard_team_member_path
    assert_response :success
    assert_difference "TeamMember.count", 0 do
      post dashboard_team_members_path,
           params: { team_member: { invitation_email: employer_2.email } }
    end
    assert_redirected_to dashboard_team_members_path
    assert_equal "Ce collaborateur est déjà invité", flash[:warning]
  end

  test "add team member that is already a member of another team" do
    employer_1 = create(:employer)
    employer_2 = create(:employer)
    employer_3 = create(:employer)
    create(:team_member, :accepted_invitation, inviter: employer_3, member: employer_2)
    sign_in employer_1
    get new_dashboard_team_member_path
    assert_response :success
    assert_difference "TeamMember.count", 0 do
      post dashboard_team_members_path,
           params: { team_member: { invitation_email: employer_2.email } }
    end
    assert_redirected_to dashboard_team_members_path
    assert_equal "Ce collaborateur fait déjà partie d’une équipe sur mon stage de troisième. Il ne pourra pas rejoindre votre équipe", flash[:alert]
  end

  # ------- Accept/refuse
    # ------- Accept
  test "invitation accepted" do
    employer_1 = create(:employer)
    employer_2 = create(:employer)
    team_member = create(:team_member,
                         inviter: employer_1,
                         member: employer_2,
                         invitation_email: employer_2.email)
    sign_in employer_2
    get new_dashboard_team_member_path
    assert_response :success
    assert_difference "TeamMember.count", 1 do
       patch join_dashboard_team_member_path( id: team_member.id),
           params: { id: team_member.id, commit: "Oui"}
    end
    assert_redirected_to dashboard_team_members_path
    assert_equal team_member.reload.aasm_state, "accepted_invitation"
  end

  test 'when two employers of different team invite a third one, ignored invitation is refused' do
    employer_1 = create(:employer)
    employer_2 = create(:employer)
    employer_3 = create(:employer)
    team_member_1 = create(:team_member,
                           inviter: employer_1,
                           member: employer_3,
                           invitation_email: employer_3.email)
    team_member_2 = create(:team_member,
                           inviter: employer_2,
                           member: employer_3,
                           invitation_email: employer_3.email)
    sign_in employer_3
    get new_dashboard_team_member_path
    assert_response :success
    assert_difference "TeamMember.count", 1 do
      patch join_dashboard_team_member_path( id: team_member_1.id),
            params: { id: team_member_1.id, commit: "Oui" }
    end
    assert_redirected_to dashboard_team_members_path
    assert_equal "accepted_invitation", team_member_1.reload.aasm_state
    assert_equal "refused_invitation", team_member_2.reload.aasm_state
  end

  test 'when two employers of different teams invite each other, ignored invitation is deleted' do
    employer_1 = create(:employer)
    employer_2 = create(:employer)
    team_member_1 = create(:team_member,
                           inviter: employer_1,
                           member: employer_2,
                           invitation_email: employer_2.email)
    team_member_2 = create(:team_member,
                           inviter: employer_2,
                           member: employer_1,
                           invitation_email: employer_1.email)
    sign_in employer_2
    get new_dashboard_team_member_path
    assert_response :success
    assert_no_difference "TeamMember.count" do
      patch join_dashboard_team_member_path(id: team_member_1.id),
            params: { id: team_member_1.id, commit: "Oui" }
    end
    assert_redirected_to dashboard_team_members_path
    assert_equal team_member_1.reload.aasm_state, "accepted_invitation"
    assert_nil TeamMember.find_by(id: team_member_2.id)
  end

    # ------- Refuse
  test "invitation refused" do
    employer_1 = create(:employer)
    employer_2 = create(:employer)
    team_member = create(:team_member, inviter: employer_1, member: employer_2, invitation_email: employer_2.email)
    sign_in employer_1
    get new_dashboard_team_member_path
    assert_response :success
    assert_difference "TeamMember.count", 0 do
       patch join_dashboard_team_member_path( id: team_member.id),
           params: { id: team_member.id, commit: "Non"}
    end
    assert_redirected_to dashboard_team_members_path
    assert_equal team_member.reload.aasm_state, "refused_invitation"
  end
  # ------- END : Accept/refuse ------------
  test "delete team member with 2 people in team" do
    employer_1 = create(:employer)
    employer_2 = create(:employer)
    employer_3 = create(:employer)
    create(:team_member,
           :accepted_invitation,
           inviter: employer_1,
           member: employer_2,
           invitation_email: employer_2.email)
    team_member = create(:team_member,
           :accepted_invitation,
           inviter: employer_1,
           member: employer_1,
           invitation_email: employer_2.email)
    # Unused context
    create(:team_member,
           inviter: employer_1,
           member: employer_3,
           invitation_email: employer_3.email)

    sign_in employer_2
    get new_dashboard_team_member_path
    assert_response :success
    assert_difference "TeamMember.count", -2 do
      delete dashboard_team_member_path(team_member)
    end
    assert_redirected_to dashboard_team_members_path
    assert_equal "Membre d'équipe supprimé avec succès. Votre équipe a été dissoute", flash[:success]
  end

  test "delete team member with 3 people in team" do
    employer_1 = create(:employer)
    employer_2 = create(:employer)
    employer_3 = create(:employer)
    create(:team_member,
           :accepted_invitation,
           inviter: employer_1,
           member: employer_2,
           invitation_email: employer_2.email)
    team_member = create(:team_member,
           :accepted_invitation,
           inviter: employer_1,
           member: employer_1,
           invitation_email: employer_2.email)
    create(:team_member,
           :accepted_invitation, # team with 3 people
           inviter: employer_1,
           member: employer_3,
           invitation_email: employer_3.email)

    sign_in employer_2
    get new_dashboard_team_member_path
    assert_response :success
    assert_difference "TeamMember.count", -1 do
      delete dashboard_team_member_path(team_member)
    end
    assert_redirected_to dashboard_team_members_path
    assert_equal "Membre d'équipe supprimé avec succès.", flash[:success]
  end
end
