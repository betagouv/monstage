class TeamMember < ApplicationRecord
   # Relations
  has_many :employers, dependent: :destroy

  # Validations

  # TODO
  # before_validation :check_new_member_validity, on: :create

  private

  # def check_new_member_validity
  #   if employer.team_members.count >= 2
  #     errors.add(:base, "Vous ne pouvez pas ajouter ce nouveau membre à votre équipe, car il appartient déjà à une équipe")
  #   end
  # end

end
