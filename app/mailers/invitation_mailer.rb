class InvitationMailer < ApplicationMailer
  def staff_invitation(from:, invitation: )

    @from        = from.email
    @school_name = from.school.name
    @from_name   = from.formal_name
    @invitation  = invitation
    @to          = invitation.email
    @role        = invitation.role
    @invitation_first_name = invitation.first_name
    @invitation_last_name  = invitation.last_name
    @school_manager_id = invitation.user_id
    @link = new_user_registration_url(
      as: 'SchoolManagement',
      email: @to,
      role: @role,
      first_name: @invitation_first_name,
      last_name: @invitation_last_name,
      school_manager_id: @school_manager_id
    )

    mail(
      from: @from,
      to: @to,
      subject: "Invitation à rejoindre monstagedetroisieme.fr"
    )
  end
end
