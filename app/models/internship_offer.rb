class InternshipOffer < ApplicationRecord

  validates :title, :description, :sector, :can_be_applied_for, :tutor_name, :tutor_phone, :supervisor_email, presence: true

  def available_all_year?
    week_day_start.blank? && week_day_end.blank?
  end
end
