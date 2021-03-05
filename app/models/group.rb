# frozen_string_literal: true

class Group < ApplicationRecord
  scope :is_public, -> { where(is_public: true) }
  scope :is_private, -> { where(is_public: false) }
  has_many :internship_offers
  has_many :organisations
end
