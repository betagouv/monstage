class Identity < ApplicationRecord
  # Relations
  belongs_to :user, optional: true
  belongs_to :school
  belongs_to :class_room, optional: true

  # Validations
  validates :first_name, :last_name, :birth_date, :token,
            presence: true

  after_initialize :generate_token, unless: :token

  private

  def generate_token
    self.token = SecureRandom.hex(12)
  end
  
end