# frozen_string_literal: true

class Favorite < ApplicationRecord
  belongs_to :user
  belongs_to :internship_offer

  validates_uniqueness_of :user_id, scope: :internship_offer_id
end
