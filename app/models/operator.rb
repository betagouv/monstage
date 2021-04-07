# frozen_string_literal: true

class Operator < ApplicationRecord
  has_many :operators, class_name: 'Users::Operator'
  has_many :internship_offers, through: :operators
  has_many :organisations, through: :internship_offers
end
