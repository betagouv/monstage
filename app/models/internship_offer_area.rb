class InternshipOfferArea < ApplicationRecord
  belongs_to :employer, polymorphic: true
  has_many :internship_offers

  validates :name,
            presence: true,
            uniqueness: { scope: :employer_id }
end
