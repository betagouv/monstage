class InternshipOffer < ApplicationRecord
  include Discard::Model

  validates :title,
            :description,
            :sector,
            :can_be_applied_for,
            :tutor_name,
            :tutor_phone,
            :supervisor_email,
            :is_public,
            presence: true

  has_many :internship_offer_weeks, dependent: :destroy
  has_many :weeks, through: :internship_offer_weeks

  def available_all_year?
    week_day_start.blank? && week_day_end.blank?
  end
end
