module Presenters
  class InternshipOffer
    def filter_options
      {
        component_label: 'Filtrer par',
        mobile_extra_option: [{
          value: 'all',
          id: 'search-by-all',
          label: 'Toutes les filières'
        }],
        options: [
          { value: 'troisieme_generale',
            id: 'search-by-troisieme-generale',
            label: '3è'},
          { value: 'troisieme_segpa',
            id: 'search-by-troisieme-segpa',
            label: '3e SEGPA'},
          { value: 'troisieme_prepa_metiers',
            id: 'search-by-troisieme-prepa-metiers',
            label: '3e prépa métiers'}
        ]
      }
    end

    def weeks_boundaries
      "Du #{I18n.localize(internship_offer.first_date, format: :human_mm_dd_yyyy)}" \
      " au #{I18n.localize(internship_offer.last_date, format: :human_mm_dd_yyyy)}"
    end

    def remaining_places
      count = internship_offer.remaining_places_count
      "#{count} #{"place".pluralize(count)} #{"disponible".pluralize(count)}"
    end

    private

    attr_reader :internship_offer

    def initialize(internship_offer)
      @internship_offer = internship_offer
    end

  end
end
