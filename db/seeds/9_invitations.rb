def populate_invitations
  Invitation.create!(
    first_name: 'Nestor',
    last_name: 'Burma',
    email: 'invited_nestor@ac-paris.fr',
    role: 'teacher',
    user_id: fetch_school_manager.id,
    sent_at: 2.days.ago
  )
end

def fetch_school_manager
  Users::SchoolManagement.find_by(role: 'school_manager')
end

call_method_with_metrics_tracking([:populate_invitations])