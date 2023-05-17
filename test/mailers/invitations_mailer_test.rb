require "test_helper"

class InvitationsMailerTest < ActionMailer::TestCase
  include EmailSpamEuristicsAssertions

  test '.weekly_kpis_email sends email to recipient' do
    school_manager = create(:school_manager)
    invitation = create(:invitation)
    email = InvitationMailer.staff_invitation(
      from: school_manager,
      invitation: invitation
    )
    email.deliver_now
    assert_emails 1
    assert_equal [school_manager.email], email.from
    assert_equal [invitation.email], email.to
    assert_match "Elle vous permettra d'accompagner et de suivre vos", email.body.encoded
    refute_email_spammyness(email)
  end

end
