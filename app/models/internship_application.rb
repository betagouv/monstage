class InternshipApplication < ApplicationRecord
  include AASM
  PAGE_SIZE = 10

  belongs_to :internship_offer_week
  counter_culture :internship_offer_week,
                  column_name: proc  { |model| model.approved? ? 'blocked_applications_count' : nil }

  belongs_to :student, class_name: 'Users::Student', foreign_key: 'user_id'

  has_one :internship_offer, through: :internship_offer_week
  has_one :week, through: :internship_offer_week


  validates :motivation, :internship_offer_week, presence: true
  before_validation :internship_offer_week_has_spots_left, on: :create

  paginates_per PAGE_SIZE

  def internship_offer_week_has_spots_left
    unless internship_offer_week && internship_offer_week.has_spots_left?
      errors[:base] << "Impossible de candidater car l'offre est déjà pourvue"
    end
  end

  aasm do
    state :submitted, initial: true
    state :approved, :rejected

    event :approve do
      transitions from: :submitted, to: :approved
    end

    event :reject do
      transitions from: :submitted, to: :rejected
    end
  end
end
