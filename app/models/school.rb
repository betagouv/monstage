class School < ApplicationRecord
  has_many :students

  def coordinates=(coordinates)
    super(geo_point_factory(latitude: coordinates[:latitude],
                            longitude: coordinates[:longitude]))
  end
end
