# Preview all emails at http://localhost:3000/rails/mailers/invitations_mailer
class InvitationsMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/invitations_mailer/staff_invitation
  def staff_invitation
    from = Users::SchoolManagement.where(role: 'school_manager').first
    invitation = Invitation.first
    InvitationMailer.staff_invitation(from: from, invitation: invitation)
  end

end
