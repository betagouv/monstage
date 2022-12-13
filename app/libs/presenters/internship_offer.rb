module Presenters
  class InternshipOffer

    def weeks_boundaries
      "Du #{I18n.localize(internship_offer.first_date, format: :human_mm_dd_yyyy)}" \
      " au #{I18n.localize(internship_offer.last_date, format: :human_mm_dd_yyyy)}"
    end

    def remaining_seats
      count = internship_offer.remaining_seats_count
      "#{count} #{"place".pluralize(count)} #{"disponible".pluralize(count)}"
    end

    private

    attr_reader :internship_offer

    def initialize(internship_offer)
      @internship_offer = internship_offer
    end

  end
end