class TeamMember < ApplicationRecord
   # Relations
  belongs_to :inviter,
             class_name: 'User',
             optional: true
  belongs_to :member,
             class_name: 'User',
             optional: true


  # Validations
  validates :email,
            uniqueness: { scope: :member_id,
                          message: "Vous avez déjà invité ce membre dans votre équipe" },
            on: :create

  # instance methods
  def presenter(current_user)
    @presenter ||= ::Presenters::TeamMember.new(team_member: self, current_user: current_user)
  end
end
