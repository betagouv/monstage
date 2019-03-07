class School < ApplicationRecord
  has_many :students

  has_many :school_internship_weeks
  has_many :weeks, through: :school_internship_weeks

  def coordinates=(coordinates)
    super(geo_point_factory(latitude: coordinates[:latitude],
                            longitude: coordinates[:longitude]))
  end

  def select_text_method
    "#{name} - #{city} - #{postal_code}"
  end

  def self.grouped_by_short_postal_code
    School.all.order(:postal_code).inject({}) do |acc, school|
      short_postal_code = "#{school.postal_code[0..1]} - #{school.departement_name}" rescue "?"
      acc[short_postal_code] = [] unless acc[short_postal_code]
      acc[short_postal_code].push([school.select_text_method, school.id ])
      acc
    end
  end
end
