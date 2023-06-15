class TeamMemberInvitation < ApplicationRecord
  belongs_to :user, optional: true

  # instance methods
  def presenter
    @presenter ||= ::Presenters::TeamMemberInvitation.new(self)
  end
end
