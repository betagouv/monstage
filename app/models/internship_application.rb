class InternshipApplication < ApplicationRecord
  belongs_to :internship_offer_week
  belongs_to :student, class_name: 'User', foreign_key: 'user_id'

  has_one :internship_offer, through: :internship_offer_week
  has_one :week, through: :internship_offer_week

  validates :motivation, :internship_offer_week, presence: true
end
