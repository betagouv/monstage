class Operator < ApplicationRecord
  has_many :internship_offer_operators, dependent: :nullify
  has_many :internship_offers, through: :internship_offer_operators
  has_many :operators, class_name: 'Users::Operator'
end
