# frozen_string_literal: true

class Favorite < ApplicationRecord
 
  # belongs_to :student, class_name: 'Users::Student'
  belongs_to :user
  belongs_to :internship_offer
  

end
