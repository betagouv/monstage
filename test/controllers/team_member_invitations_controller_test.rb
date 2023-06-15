require "test_helper"

class TeamMemberInvitationControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  test "add team member" do
    employer_1 = create(:employer)
    employer_2 = create(:employer)
    sign_in employer_1
    get new_dashboard_team_member_invitation_path
    assert_response :success
    assert_difference "TeamMember.count", 1 do
      post dashboard_team_members_path, params: { team_member_invitation: { invitation_email: employer_2.email } }
    end
    assert_redirected_to new_dashboard_team_member_invitation_path
    assert_equal "Membre d'équipe créé avec succès", flash[:success]
  end
end