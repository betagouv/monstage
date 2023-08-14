require "test_helper"

class TeamMemberInvitationTest < ActiveSupport::TestCase
  test "aasm_state default" do
    team_member_invitation = TeamMemberInvitation.new
    assert_equal team_member_invitation.aasm_state, "pending_invitation"
  end

  test "aasm_state accepted_invitation" do
    employer = create(:employer)
    invitee_employer = create(:employer)
    team_member_invitation = create(:team_member_invitation,
                         inviter_id: employer.id,
                         member_id: invitee_employer.id,
                         invitation_email: invitee_employer.email
    )
    assert 1, employer.team.team_size
    team_member_invitation.accept_invitation!
    assert_equal team_member_invitation.aasm_state, "accepted_invitation"
    assert 2, employer.team.team_size
    assert 2, invitee_employer.team.team_size
    assert_equal 2, TeamMemberInvitation.all.count
  end

  test "no fusion between teams" do
    employer = create(:employer)
    invitee_employer = create(:employer)
    team_member_invitation = create(:team_member_invitation,
                         inviter_id: employer.id,
                         member_id: invitee_employer.id,
                         invitation_email: invitee_employer.email
    )
    team_member_invitation.accept_invitation!
    employer_2 = create(:employer)
    invitee_employer_2 = create(:employer)
    team_member_invitation = create(:team_member_invitation,
                         inviter_id: employer_2.id,
                         member_id: invitee_employer_2.id,
                         invitation_email: invitee_employer_2.email
    )
    team_member_invitation.accept_invitation!
    assert 2, employer_2.team.team_size
    assert 2, invitee_employer_2.team.team_size
    assert_equal 4, TeamMemberInvitation.all.count
  end

  test 'team_members refuse invitation' do
    employer = create(:employer)
    invitee_employer = create(:employer)
    team_member_invitation = create(:team_member_invitation,
                         inviter_id: employer.id,
                         member_id: invitee_employer.id,
                         invitation_email: invitee_employer.email
    )
    team_member_invitation.refuse_invitation!
    refute employer.team.alive?
    assert employer.team.not_exists?
    assert 1, TeamMemberInvitation.refused_invitation.count
  end

  test 'team does not exist with a sole user' do
    employer = create(:employer)
    team_member_invitation = create(:team_member_invitation,
                         inviter_id: employer.id,
                         member_id: nil,
                         invitation_email: 'testo@mail.fr')
    assert employer.team.not_exists?
  end
end
