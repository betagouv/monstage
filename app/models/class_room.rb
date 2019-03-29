class ClassRoom < ApplicationRecord
  belongs_to :school
  has_many :students, class_name: 'Users::Student'

  def to_s
    name
  end
end
