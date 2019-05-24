require 'forwardable'
module Presenters
  class InternshipOfferStatsByGroupName < GroupedInternshipOfferStats
    def report_row_title
      internship_offer.group.present? ?
        internship_offer.group :
        "Indépendant"
    end
  end
end
