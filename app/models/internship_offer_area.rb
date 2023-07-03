class InternshipOfferArea < ApplicationRecord
  belongs_to :employer, class_name: "User"
  has_many :internship_offers

  validates :employer, :name, presence: true
  validates :name, uniqueness: { scope: :employer_id }

end
