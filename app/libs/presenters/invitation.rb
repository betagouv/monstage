module Presenters
  class Invitation
    def full_name
      "#{first_name.capitalize} #{last_name.capitalize}"
    end

    def school_name
      school_manager&.school&.name
    end

    def status
      user = ::Users::SchoolManagement.find_by(email: email)
      return { type: 'success', label: 'inscrit', status: :subscribed} if user.present?
      return { type: 'new', label: 'Invitation envoyée', status: :email_sent} if sent_at.present?

      nil
    end

    attr_reader :email, :role, :first_name, :last_name, :school_manager, :sent_at

    private

    def initialize(invitation)
      @invitation     = invitation
      @email          = @invitation.email
      @role           = @invitation.role
      @first_name     = @invitation.first_name
      @last_name      = @invitation.last_name
      @sent_at        = @invitation.sent_at
      @school_manager = @invitation&.school_manager
    end
  end
end