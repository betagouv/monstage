# frozen_string_literal: true
module Api
  class School < ApplicationRecord
    include Nearbyable
    include PgSearch::Model

    has_many :class_rooms, dependent: :destroy

    pg_search_scope :search_city,
                    against: :city,
                    ignoring: :accents,
                    using: {
                      tsearch: {
                        dictionary: 'public.fr',
                        # use ts_vector field for search, maintened via trigger
                        tsvector_column: "city_tsv",
                        prefix: true,
                        highlight: {
                          StartSel: '<b>',
                          StopSel: '</b>'
                        }
                      }
                    }

    scope :autocomplete_by_city, -> (term:, limit: 15) {
      search_city(term)
        .with_pg_search_highlight
    }

    def uniq_city_name
      "#{pg_search_highlight} (#{zipcode})"
    end

    def pg_search_highlight
      attributes["pg_search_highlight"]
    end

    def as_json(options={})
      super(options.merge(only: %i[id name department zipcode],
                          methods: %i[pg_search_highlight class_rooms]))
    end
  end
end
