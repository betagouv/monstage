# frozen_string_literal: true

class School < ApplicationRecord
  include Nearbyable

  has_many :users, foreign_type: 'type'
  has_many :students, dependent: :nullify,
                      class_name: 'Users::Student'
  has_many :main_teachers, dependent: :nullify,
                           class_name: 'Users::MainTeacher'
  has_many :teachers, dependent: :nullify,
                      class_name: 'Users::Teacher'
  has_many :others, dependent: :nullify,
                    class_name: 'Users::Other'
  has_one :school_manager, class_name: 'Users::SchoolManager'

  has_many :class_rooms, dependent: :destroy
  has_many :school_internship_weeks, dependent: :destroy
  has_many :weeks, through: :school_internship_weeks


  def select_text_method
    "#{name} - #{city} - #{zipcode}"
  end

  def to_s
    name
  end
end
