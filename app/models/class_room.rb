class ClassRoom < ApplicationRecord
  belongs_to :school
  has_many :students, class_name: 'Users::Student'
  has_many :main_teachers, class_name: 'Users::MainTeacher'

  def to_s
    name
  end
end
