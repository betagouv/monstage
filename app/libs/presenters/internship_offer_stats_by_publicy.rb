# frozen_string_literal: true

module Presenters
  class InternshipOfferStatsByPublicy < GroupedInternshipOfferStats
    def report_row_title
      internship_offer.is_public? ?
        'Sous total Secteur Public' :
        'Sous total Secteur Privé'
    end
  end
end
