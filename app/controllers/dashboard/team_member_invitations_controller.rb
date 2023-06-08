module Dashboard
  class TeamMemberInvitationsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_employer, only: [:create]

    def index
      authorize! :manage_teams, TeamMemberInvitation
      @team_member_invitations = TeamMemberInvitation.all
    end

    def new
      authorize! :manage_teams, TeamMemberInvitation
      @team_member_invitation = TeamMemberInvitation.new
    end

    def create
      puts '================'
      puts "@team_member_invitation_params : #{@team_member_invitation_params}"
      puts '================'
      puts ''
      authorize! :manage_teams, TeamMemberInvitation
      if current_user.team_member_invitations.create(team_member_invitation_params) && after_invitation_processes
        redirect_to dashboard_team_members_path,
                    flash: { success: 'Membre d\'équipe créé avec succès' }
      else
        render :new, status: :bad_request
      end
    end

    private

    def after_invitation_processes
      return true
    end

    def team_member_invitation_params
      puts '================'
      puts "params : #{params}"
      puts "params.permit(team_member_invitations) : #{params.permit(team_member_invitations)}"
      puts '================'
      puts ''

      # order matters here
      params.permit(team_member_invitations: { emails: [] })
            .require(:team_member_invitations)
    end

    def set_employer
      # @employer = Employer.find(email: team_member_invitation_params.first[:email])
    end
  end
end