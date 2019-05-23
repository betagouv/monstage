module Presenters
  class InternshipOfferStatsBySector < GroupedInternshipOfferStats
    def report_row_title
      internship_offer.sector_name
    end
  end
end
