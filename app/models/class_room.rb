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

  scope :current, -> {where(anonymized: false)}

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
