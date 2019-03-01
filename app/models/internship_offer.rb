class InternshipOffer < ApplicationRecord
  include Discard::Model

  validates :title,
            :description,
            :sector,
            :max_candidates,
            :tutor_name,
            :tutor_phone,
            :tutor_email,
            :employer_name,
            :employer_street,
            :employer_zipcode,
            :employer_city,
            :coordinates,
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

  attr_reader :autocomplete

  def available_all_year?
    week_day_start.blank? && week_day_end.blank?
  end

  def coordinates=(coordinates)
    super(geo_point_factory(latitude: coordinates[:latitude],
                            longitude: coordinates[:longitude]))
  end

  def is_individual?
    max_candidates <= 1
  end
end
