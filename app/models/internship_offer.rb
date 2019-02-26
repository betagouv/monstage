class InternshipOffer < ApplicationRecord
  include Discard::Model

  validates :title,
            :description,
            :sector,
            :max_candidates,
            :tutor_name,
            :tutor_phone,
            :employer_street,
            :employer_zipcode,
            :employer_city,
            presence: true

  validates :can_be_applied_for, inclusion: { in: [true, false] }
  validates :is_public, inclusion: { in: [true, false] }

  validates :max_candidates, numericality: { only_integer: true, greater_than: 0 },
                             unless: :can_be_applied_for?
  validates :max_weeks, numericality: { only_integer: true, greater_than: 0 }

  validates :weeks, presence: true

  has_many :internship_offer_weeks, dependent: :destroy
  has_many :weeks, through: :internship_offer_weeks
  # accepts_nested_attributes_for :internship_offer_weeks, :weeks

  belongs_to :operator, class_name: 'User',
                        foreign_key: 'operator_id',
                        optional: true

  def available_all_year?
    week_day_start.blank? && week_day_end.blank?
  end

  private

end
