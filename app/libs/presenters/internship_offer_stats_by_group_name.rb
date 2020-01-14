# frozen_string_literal: true

require 'forwardable'
module Presenters
  class InternshipOfferStatsByGroupName < GroupedInternshipOfferStats
    def report_row_title
      internship_offer.group.present? ?
        internship_offer.group.name :
        'Indépendant'
    end
  end
end
