class ClassRoom < ApplicationRecord
  belongs_to :school
  has_many :students

  def to_s
    name
  end
end
