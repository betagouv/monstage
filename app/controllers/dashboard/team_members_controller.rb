module Dashboard
  class TeamMembersController < ApplicationController
    before_action :authenticate_user!
    before_action :fetch_invitation, only: %i[destroy join]
    before_action :authorize_member_inviting

    def index
      authorize! :manage_teams, TeamMember
      @team_members = current_user.team_members
      @page = existing_team_or_invitations? ? :index : :presentation
    end

    def new
      @team_member = TeamMember.new
    end

    def create
      case check_invitation(team_member_params[:invitation_email])
      when :ok
        params = team_member_params.merge(inviter_id: team_inviter_id)
        @team_member = TeamMember.create!(params)
        flash = { success: 'Membre d\'équipe invité avec succès' }
      when :invited
        flash = { warning: 'Ce collaborateur est déjà invité' }
      when :already_in_team
        flash = { warning: 'Ce collaborateur fait déjà partie de l\'équipe' }
      when :in_another_team
        flash = { alert: 'Ce collaborateur fait déjà partie d’une équipe sur mon stage de troisième. Il ne pourra pas rejoindre votre équipe' }
      when :self_invitation
        flash = { alert: 'Vous ne pouvez pas vous inviter vous-même' }
      else
        render(:new, status: :bad_request) and return
      end
      redirect_to dashboard_team_members_path, flash: flash
    end

    # when accepting an invitation or not 
    def join
      authorize! :manage_teams, @team_member
      action =  params[:commit] == "Oui" ? :accept_invitation! : :refuse_invitation!
      @team_member.send(action)
      redirect_to dashboard_team_members_path
    end

    def destroy
      authorize! :destroy, @team_member
      message = 'Membre d\'équipe supprimé avec succès.'
      if @team_member.not_in_a_team?
        @team_member.destroy
      else
        team = Team.new(@team_member)
        message = "#{message} Votre équipe a été dissoute" if team.team_size <= 2
        team.remove_member
      end
      redirect_to dashboard_team_members_path, flash: { success: message }
    rescue ActiveRecord::RecordInvalid
      render :new, status: :bad_request
    end

    def team_inviter_id
      current_user.team.try(:team_owner_id) || current_user.id
    end


    attr_accessor :check_result, :accept_invitation

    private

    def change_owner(target_id:, collection:)
      collection.each do |team_member|
        team_member.update!(inviter_id: target_id)
      end
    end

    def existing_team_or_invitations?
      current_user.team.alive? ||
        current_user.pending_invitations_to_my_team.present?
    end

    def authorize_member_inviting
      authorize! :manage_teams, TeamMember
    end

    def check_invitation(email)
      ::Services::TeamMemberInvitationValidator.new(email: email, current_user: current_user)
                                               .check_invitation
    end

    def fetch_invitation
      @team_member = TeamMember.find(params[:id])
    end

    def team_member_params
      params.require(:team_member)
            .permit( :invitation_email )
    end
  end
end
