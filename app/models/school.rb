class School < ApplicationRecord
  include Nearbyable
  has_many :students, dependent: :nullify,
                      class_name: 'Users::Student'
  has_many :main_teachers, dependent: :nullify,
                           class_name: 'Users::MainTeacher'
  has_many :teachers, dependent: :nullify,
                      class_name: 'Users::Teacher'

  has_one :school_manager, class_name: 'Users::SchoolManager'

  has_many :class_rooms, dependent: :destroy


  has_many :school_internship_weeks, dependent: :destroy
  has_many :weeks, through: :school_internship_weeks

  def select_text_method
    "#{name} - #{city} - #{zipcode}"
  end

  def formatted_autocomplete_address
    [
      street,
      city,
      zipcode
    ].compact.uniq.join(', ')
  end

  def self.grouped_by_short_zipcode
    School.all.order(:zipcode).inject({}) do |acc, school|
      short_zipcode = "#{school.zipcode[0..1]} - #{school.departement_name}" rescue "?"
      acc[short_zipcode] = [] unless acc[short_zipcode]
      acc[short_zipcode].push([school.select_text_method, school.id ])
      acc
    end
  end

  def to_s
    name
  end
end
