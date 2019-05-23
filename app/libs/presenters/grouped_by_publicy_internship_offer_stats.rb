require 'forwardable'
module Presenters
  class GroupedByPublicyInternshipOfferStats < GroupedInternshipOfferStats

    def report_row_title
      internship_offer.is_public? ?
        'Secteur Public' :
        'Secteur Privé'
    end
  end
end
