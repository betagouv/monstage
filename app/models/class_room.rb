# frozen_string_literal: true

class ClassRoom < ApplicationRecord
  include SchoolTrackable

  belongs_to :school
  has_many :students, class_name: 'Users::Student',
                      dependent: :nullify
  has_many :school_managements, class_name: 'Users::SchoolManagement',
                                dependent: :nullify do
    def main_teachers
      where(role: :main_teacher)
    end
  end

  def middle_school?
    [troisieme_segpa?, troisieme_generale?, troisieme_prepa_metier?].any?
  end

  def high_school?
    bac_pro?
  end

  def applicable?(internship_offer)
    return true if internship_offer.free_date? && high_school?
    return true if internship_offer.weekly? && middle_school?

    false
  end

  def to_s
    name
  end
end
