# frozen_string_literal: true

class ClassRoom < ApplicationRecord
  belongs_to :school
  has_many :students, class_name: 'Users::Student',
                      dependent: :nullify
  has_many :main_teachers, class_name: 'Users::MainTeacher',
                           dependent: :nullify

  def to_s
    name
  end
end
