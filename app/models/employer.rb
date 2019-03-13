class Employer < User
  has_many :internship_offers, dependent: :destroy

  scope :targeted_internship_offers, -> (user:) { user.internship_offers }
end
