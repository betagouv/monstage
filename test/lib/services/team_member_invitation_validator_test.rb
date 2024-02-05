require 'test_helper'

module Services
  class TeamMemberInvitationValidatorTest < ActiveSupport::TestCase
    test 'already invited ' do
      employer         = create(:employer)
      current_user     = employer
      invitee_employer = create(:employer)
      team_member_invitation = create(:team_member_invitation,
                                      inviter_id: employer.id,
                                      member_id: invitee_employer.id,
                                      invitation_email: invitee_employer.email
      )
      assert TeamMemberInvitation.exists?(invitation_email: invitee_employer.email, inviter_id: current_user.team_id)
      validator = Services::TeamMemberInvitationValidator.new(email: invitee_employer.email, current_user: current_user)
      assert_equal :invited, validator.check_invitation
    end

    test 'already in team' do
      employer         = create(:employer)
      current_user     = employer
      invitee_employer = create(:employer)
      team_member_invitation = create(:team_member_invitation,
                                      inviter_id: employer.id,
                                      member_id: invitee_employer.id,
                                      invitation_email: invitee_employer.email
      )
      assert TeamMemberInvitation.exists?(invitation_email: invitee_employer.email, inviter_id: current_user.team_id)
    end
    
    test 'bad format email invitation' do
      current_user     = create(:employer)
      invalid_emails = ['invalid_email', 'invalid_email@', 'xxxxxxxxxxxxx@xxxxxx', 'invalid_email@domain.']
      invalid_emails.each do |invalid_email|
        validator = Services::TeamMemberInvitationValidator.new(email: invalid_email, current_user: current_user)
        assert_equal :invalid_email, validator.check_invitation
      end
    end
  end
end