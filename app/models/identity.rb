class Identity < ApplicationRecord
  # Relations
  belongs_to :user, optional: true
  belongs_to :school
  belongs_to :class_room, optional: true

  # Validations
  validates :first_name, :last_name, :birth_date,
            presence: true

  # validates :email, uniqueness: { allow_blank: true },
  #                   format: { with: Devise.email_regexp },
  #                   allow_blank: true

  # validate :email_user_uniqueness

  private

  # def email_uniqueness
  #   # TO DO check in user
  #   return unless email && User.find_by_email(email)
  #   errors.add(email: 'Cette adresse email est déjà associée à un compte.')
  # end
end
