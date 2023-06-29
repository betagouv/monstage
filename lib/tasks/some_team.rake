# call by clever cloud cron daily at 9am
# which does not support custom day cron. so inlined in code
desc 'erase and create Teams'
task create_teams: :environment do
  TeamMemberInvitation.delete_all
  TeamMemberInvitation.create(inviter_id: 1, member_id: 2, invitation_email: 'other_employer@ms3e.fr', aasm_state: :accepted_invitation)
  TeamMemberInvitation.create(inviter_id: 1, member_id: 1, invitation_email: 'employer@ms3e.fr', aasm_state:  :accepted_invitation)
  TeamMemberInvitation.create(inviter_id: 1,  invitation_email: 'free@ms3e.fr')
  TeamMemberInvitation.create(inviter_id: 1,  invitation_email: 'bagoo@ms3e.fr', aasm_state: :refused_invitation)
end
