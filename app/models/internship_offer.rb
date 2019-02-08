class InternshipOffer < ApplicationRecord

  def available_all_year?
    week_day_start.blank? && week_day_end.blank?
  end
end
