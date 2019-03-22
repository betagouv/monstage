class InternshipApplication < ApplicationRecord
  include AASM

  belongs_to :internship_offer_week
  belongs_to :student, class_name: 'Users::Student', foreign_key: 'user_id'

  has_one :internship_offer, through: :internship_offer_week
  has_one :week, through: :internship_offer_week

  validates :motivation, :internship_offer_week, presence: true

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
