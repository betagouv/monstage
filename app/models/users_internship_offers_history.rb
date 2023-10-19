class UsersInternshipOffersHistory < ActiveRecord::Base
  # validations
  validates :user_id, presence: true
  validates :internship_offer_id, presence: true

  # relations
  belongs_to :user
  belongs_to :internship_offer
  
end