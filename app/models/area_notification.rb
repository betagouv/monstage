class AreaNotification < ApplicationRecord
  belongs_to :user
  belongs_to :internship_offer_area
end
