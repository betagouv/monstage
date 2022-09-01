# frozen_string_literal: true

class ClassRoom < ApplicationRecord
  include SchoolTrackable

  belongs_to :school
  belongs_to :main_teacher, class_name: "Users::SchoolManagement", -> { where role: "main_teacher" }, foreign_key: "main_teacher_id"
  has_many :students, class_name: 'Users::Student',
                      dependent: :nullify
  has_many :school_managements, class_name: 'Users::SchoolManagement',
                                dependent: :nullify do
    def main_teachers
      where(role: :main_teacher)
    end
  end

  def main_teacher
    school_managements&.main_teachers&.last
  end

  def fit_to_weekly?
    try(:troisieme_generale?)
  end

  def fit_to_free_date?
    !fit_to_weekly?
  end

  def applicable?(internship_offer)
    return true if internship_offer.free_date? && fit_to_free_date?
    return true if internship_offer.weekly? && fit_to_weekly?

    false
  end

  def to_s
    name
  end
end
