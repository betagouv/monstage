class PagesController < ApplicationController
  def statistiques
    @offers = InternshipOffer.during_current_year
    @departments = InternshipOffer.pluck(:department).uniq.reject(&:blank?)
    @groups = InternshipOffer.pluck(:group_name).uniq.reject(&:blank?)
  end

end
