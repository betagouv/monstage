module Dashboard
  class TeamMemberInvitationsController < ApplicationController
    before_action :authenticate_user!
    before_action :fetch_invitation, only: %i[destroy join]
    before_action :authorize_member_inviting

    def index
      authorize! :manage_teams, TeamMemberInvitation
      @team_members = current_user.pending_invitations_to_my_team.to_a +
                      current_user.refused_invitations.to_a +
                      current_user.team&.team_members.to_a
      @page = @team_members.count.positive? ? :index : :presentation
    end

    def new
      @team_member_invitation = TeamMemberInvitation.new
    end

    def create
      case check_invitation(team_member_invitation_params[:invitation_email])
      when :ok
        params = team_member_invitation_params.merge(inviter_id: current_user.team_id)
        @team_member_invitation= TeamMemberInvitation.new(params)
        @team_member_invitation.save!
        @team_member_invitation.send_invitation
        flash = { success: 'Membre d\'équipe invité avec succès' }
      when :invited
        flash = { warning: 'Ce collaborateur est déjà invité' }
      when :already_in_team
        flash = { warning: 'Ce collaborateur fait déjà partie de l\'équipe' }
      when :in_another_team
        flash = { alert: 'Ce collaborateur fait déjà partie d’une équipe sur mon stage de troisième. Il ne pourra pas rejoindre votre équipe' }
      else
        render(:new, status: :bad_request) and return
      end
      redirect_to dashboard_team_member_invitations_path, flash: flash
    end

    # when accepting an invitation or not
    def join
      authorize! :manage_teams, @team_member_invitation
      flash = {}
      if @team_member_invitation.pending_invitation?
        action =  params[:commit] == "Oui" ? :accept_invitation! : :refuse_invitation!
        @team_member_invitation.send(action)
      else
        state = @team_member_invitation.refused_invitation? ? "refusée" : "acceptée"
        flash = {warning: "L'invitation a déjà été #{state}"}
      end
      redirect_to dashboard_team_member_invitations_path, flash: flash

    end

    def destroy
      authorize! :destroy, @team_member_invitation
      message = 'Membre d\'équipe supprimé avec succès.'
      if @team_member_invitation.not_in_a_team?
        @team_member_invitation.destroy
      else
        team = Team.new(@team_member_invitation)
        message = "#{message} Votre équipe a été dissoute" if team.team_size <= 2
        team.remove_member
      end
      redirect_to dashboard_team_member_invitations_path, flash: { success: message }
    rescue ActiveRecord::RecordInvalid
      render :new, status: :bad_request
    end

    attr_accessor :check_result, :accept_invitation

    private

    def change_owner(target_id:, collection:)
      collection.each do |team_member_invitation|
        team_member_invitation.update!(inviter_id: target_id)
      end
    end

    def authorize_member_inviting
      authorize! :manage_teams, TeamMemberInvitation
    end

    def check_invitation(email)
      ::Services::TeamMemberInvitationValidator.new(email: email, current_user: current_user)
                                               .check_invitation
    end

    def fetch_invitation
      @team_member_invitation = TeamMemberInvitation.find(params[:id])
    end

    def team_member_invitation_params
      params.require(:team_member_invitation)
            .permit( :invitation_email )
    end
  end
end
