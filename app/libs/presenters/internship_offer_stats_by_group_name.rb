require 'forwardable'
module Presenters
  class InternshipOfferStatsByGroupName < GroupedInternshipOfferStats
    def report_row_title
      internship_offer.group_name.present? ?
        internship_offer.group_name :
        "Indépendant"
    end
  end
end
