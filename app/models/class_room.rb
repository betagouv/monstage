# frozen_string_literal: true

class ClassRoom < ApplicationRecord

  enum school_track: {
    troisieme_generale: 'troisieme_generale',
    troisieme_prepa_metiers: 'troisieme_prepa_metiers',
    troisieme_segpa: 'troisieme_segpa'
  }

  validates :school_track, presence: true

  belongs_to :school
  has_many :students, class_name: 'Users::Student',
                      dependent: :nullify
  has_many :school_managements, class_name: 'Users::SchoolManagement',
                                dependent: :nullify do
    def main_teachers
      where(role: :main_teacher)
    end
  end

  scope :current, -> {where(anonymized: false)}

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

  def anonymize
    Users::SchoolManagement.where(class_room_id: id)
                           .update(class_room_id: nil)
    update_columns(
      anonymized: true,
      name: 'classe archivée'
    )
  end
  alias archive anonymize
  
  def anonymized? ; anonymized; end
end
