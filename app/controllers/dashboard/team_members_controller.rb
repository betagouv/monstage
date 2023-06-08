module Dashboard
  class TeamMembersController < ApplicationController
    before_action :authenticate_user!

    def index
      authorize! :index, TeamMember
      @team_members = TeamMember.all
    end

    def new
      authorize! :create, TeamMember
      @team_member = TeamMember.new
    end

    def create
      authorize! :create, TeamMember
      @team_member = TeamMember.new(team_member_params)
      if @team_member.save
        redirect_to dashboard_team_members_path,
                    flash: { success: 'Membre d\'équipe créé avec succès' }
      else
        render :new, status: :bad_request
      end
    end

    private

    def team_member_params
      params.require(:team_member).permit(:user_id)
    end
  end
end