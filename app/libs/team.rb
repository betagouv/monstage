# Team speficics is that
# - they share the same inviter_id and
# - team_member is not nil
class Team
  def activate_member
    return if db_user.nil?

    team_member.update!(member_id: @db_user.id)
    add_owner unless id_in_team?(team_owner_id)
    team_member.reject_pending_invitations
    set_team_members
  end

  def remove_member
    if team_size <= 2
      team_members.each { |member| member.destroy }
    else
      if team_member.member_is_owner?
        target_id = fetch_another_owner_id
        change_owner(
          target_id: target_id,
          collection: team_members)
        @team_owner_id = target_id
      end
      team_member.destroy
      set_team_members
    end
  end

  def self.remove_member_by_id(db_id)
    @team_member = TeamMemberInvitation.find_by(member_id: db_id)
    return if @team_member.nil?
    Team.new(@team_member).remove_member
  end

  def alive?
    team_size.positive?
  end

  def not_exists?
    !alive?
  end

  def team_size
    return 0 unless team_owner_id

    team_members.count
  end

  def self.user_from_team_member(team_member)
    User.find_by(id: team_member.member_id)
  end

  def id_in_team?(user_id)
    team_members.pluck(:member_id).include?(user_id)
  end

  attr_accessor :user, :team_member, :team_owner_id, :team_members

  #----------------------------------
  private
  #----------------------------------

  def db_user
    @db_user ||= User.kept.find_by(email: team_member.invitation_email)
  end

  def change_owner(target_id:, collection:)
    collection.each do |member|
      next if member.member_id == target_id

      member.update!(inviter_id: target_id)
    end
  end

  def add_owner
    team_owner = User.kept.find(team_owner_id)
    return if team_owner.nil? # if ever team_owner is anonymized in between

    #Following is team creation time !
    TeamMemberInvitation.create!(
      member_id: team_owner_id,
      inviter_id: team_owner_id,
      aasm_state: :accepted_invitation,
      invitation_email: team_owner.email
    )
    team_init
  end

  def fetch_another_owner_id
    team_members.map(&:member_id)
                .reject { |id| id == team_owner_id }
                .first
  end

  def team_init
    team_double_names_harmonize
    notify
  end

  def notify
    # all areas are now shared, notifications should be settled
    user.team_areas.each do |area|
      area.area_notifications.create!(
        user: user,
        notify: true
      )
    end
  end

  def team_double_names_harmonize
    doubles = {}
    InternshipOfferArea.where(employer_id: team_members.pluck(:member_id)).each do |area|
      if doubles[area.name].nil?
        doubles[area.name] = [area]
      else
        doubles[area.name] << area
      end
    end
    doubles.each do |name, area_array|
      next if area_array.size == 1

      harmonize(area_array, name)
    end
  end

  def harmonize(area_array, name)
    area_array.each do |area|
      area.update!(name: "#{name}-#{area.employer.presenter.initials}")
    end
  end

  def set_team_member
    @team_member = base_query.find_by(member_id: user.id)
  end

  def set_team_owner_id
    @team_owner_id = @team_member&.inviter_id
  end

  def set_team_members
    if team_owner_id.nil?
      @team_members = TeamMemberInvitation.none
    else
      @team_members = base_query.where(inviter_id: team_owner_id)
    end
  end

  def base_query
    TeamMemberInvitation.accepted_invitation
  end

  def initialize(user_or_team_member)
    if user_or_team_member.is_a?(User)
      @user = user_or_team_member
      @team_member = TeamMemberInvitation.find_by(member_id: user.id)
    else
      @team_member = user_or_team_member
      @user = User.find_by(email: user_or_team_member.invitation_email)
    end
    set_team_owner_id
    set_team_members
  end
end