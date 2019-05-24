# frozen_string_literal: true

class Feedback < ApplicationRecord
  validates :email, :comment, presence: true
end
