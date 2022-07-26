# frozen_string_literal: true

class ClassRoom < ApplicationRecord

  belongs_to :school
  has_many :students, class_name: 'Users::Student',
                      dependent: :nullify
  has_many :school_managements, class_name: 'Users::SchoolManagement',
                                dependent: :nullify do
    def main_teachers
      where(role: :main_teacher)
    end
  end

  def to_s
    name
  end
end
