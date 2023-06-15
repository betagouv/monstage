module Presenters
  class TeamMember

    def full_name
      return "" if member.nil?
      return "usager disparu" if member.anonymized?
      return "#{member.first_name} #{member.last_name}"
    end

    def email
      return "" if member.nil? || member.anonymized?
      return member.email
    end

    attr_reader :team_member, :current_user, :member

    private

    def fetch_user
      User.find_by(id: team_member.member_id)
    end

    def initialize(team_member: team_member, current_user: current_user)
      @team_member = team_member
      @current_user = current_user
      @member = fetch_user
    end
  end
end