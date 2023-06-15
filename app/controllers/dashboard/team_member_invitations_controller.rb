module Dashboard
  class TeamMemberInvitationsController < ApplicationController
    before_action :authenticate_user!
    before_action :authorize_member_inviting!
    before_action :fetch_invitation, only: [:destroy]

    def index
      @team_member_invitations = current_user.team_member_invitations
      @team_members = current_user.team_members
    end

    def new
      @team_member_invitation = TeamMemberInvitation.new
    end

    def create
      byebug
      case check_invitation(team_member_invitation_params[:invitation_email])
      when :ok
        current_user.team_member_invitations.create(team_member_invitation_params)
        after_invitation_processes
        flash = { success: 'Membre d\'équipe créé avec succès' }
      when :invited
        flash = { warning: 'Ce membre est déjà invité' }
      when :already_in_team
        flash = { warning: 'Ce membre fait déjà partie de l\'équipe' }
      when :in_another_team
        flash = { alert: 'Ce membre fait déjà partie d\'une autre équipe' }
      else
        render(:new, status: :bad_request) and return
      end
      redirect_to new_dashboard_team_member_path, flash: flash
    end

    def destroy
      authorize! :destroy, @team_member_invitation
      @team_member_invitation.destroy!
      redirect_to dashboard_team_member_invitations_path,
                  flash: { success: 'Invitation supprimée avec succès' }
    rescue ActiveRecord::RecordInvalid
      render :new, status: :bad_request
    end

    attr_accessor :check_result

    private

    def authorize_member_inviting!
      authorize! :manage_teams, TeamMemberInvitation
    end

    def check_invitation(email)
      ::Services::TeamMemberInvitationValidator.new(email: email, current_user: current_user)
                                               .check_invitation
      # @check_result = ::Services::TeamMemberInvitationValidator.new(email: email, current_user: current_user)
      #                                                          .check_invitation
    end

    def after_invitation_processes
      return true
    end

    def fetch_invitation
      @team_member_invitation = TeamMemberInvitation.find(params[:id])
    end

    def team_member_invitation_params
      params.require(:team_member_invitation).permit(:invitation_email)
    end
  end
end