class PagesController < ApplicationController
  def statistiques
    @offers = InternshipOffer.during_current_year
  end

end
