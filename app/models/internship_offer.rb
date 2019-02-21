class InternshipOffer < ApplicationRecord
  include Discard::Model

  validates :title,
            :description,
            :sector,
            :can_be_applied_for,
            :max_candidates,
            :tutor_name,
            :tutor_phone,
            :supervisor_email,
            :is_public,
            :employer_street,
            :employer_zipcode,
            :employer_city,
            presence: true

  validates :max_candidates, numericality: { only_integer: true, greater_than: 0 },
                             unless: :can_be_applied_for?
  validates :max_weeks, numericality: { only_integer: true, greater_than: 0 }

  validate :at_least_one_week

  has_many :internship_offer_weeks, dependent: :destroy
  has_many :weeks, through: :internship_offer_weeks

  def available_all_year?
    week_day_start.blank? && week_day_end.blank?
  end

  private
  def at_least_one_week
    if weeks.count == 0
      errors.add :weeks, "L'offre de stage doit être disponible au moins une semaine"
    end
  end

end
