class Feedback < ApplicationRecord
  validates :email, :comment, presence: true
end
