# frozen_string_literal: true

module Api
  class School < ApplicationRecord
    include Nearbyable
    include PgSearch::Model

    has_many :class_rooms, dependent: :destroy
    has_many :school_internship_weeks, dependent: :destroy
    has_many :weeks, through: :school_internship_weeks

    pg_search_scope :search_by_name_and_city,
                    against: {
                      city: 'A',
                      name: 'B'
                    },
                    ignoring: :accents,
                    using: {
                      tsearch: {
                        dictionary: 'public.fr',
                        tsvector_column: 'city_tsv',
                        prefix: true
                      }
                    }

    scope :autocomplete_by_name_or_city, lambda { |term:|
      search_by_name_and_city(term)
        .highlight_by_city(term)
        .highlight_by_name(term)
        .select("#{table_name}.*")
    }

    scope :visible, -> { where(visible: true) }

    def as_json(options = {})
      super(options.merge(only: %i[id name department zipcode],
                          methods: %i[class_rooms] +
                                   %i[name city]) do |key,default,options|
                                    default+options
                                   end)
    end

    # private

    # autocomplete search by %i[name city]
    # following scopes declare one scope per autocomplete column
    # use PgSearch highlight feature to show matching part of columns
    #
    %i[name city].map do |highlight_column|
      # private scope only used for select
      pg_search_scope :"search_#{highlight_column}",
                      against: highlight_column,
                      ignoring: :accents,
                      using: {
                        tsearch: {
                          dictionary: 'public.fr',
                          highlight: {
                            StartSel: '<b>',
                            StopSel: '</b>'
                          }
                        }
                      }

      # make a SQL select with ts_headline (highlight part of full text search match)
      # we use previously defined pg_search_scope in order to build the right ts_headline pg call
      # see: https://www.postgresql.org/docs/current/textsearch-controls.html
      scope :"highlight_by_#{highlight_column}", lambda { |term|
        current_pg_search_scope = send(:"search_#{highlight_column}", term)
        select("#{current_pg_search_scope.tsearch.highlight.to_sql} as pg_search_highlight_#{highlight_column}")
      }

      define_method(:"match_by_#{highlight_column}?") do |term|
        current_attribute_value = send(highlight_column)
        current_pg_highlight_attribute_value = attributes["pg_search_highlight_#{highlight_column}"]

        %r{<b>.*</b>}.match?(current_pg_highlight_attribute_value) ||
          current_attribute_value.downcase.include?(term.downcase)
      end

      # read SQL result of ts_headline (highlight_by_#{highlight_column}) pg_search_highlight_#{highlight_column}
      define_method(:"pg_search_highlight_#{highlight_column}") do
        # return nil unless send(:"match_by_#{highlight_column}?", self.send(highlight_column))
        attributes["pg_search_highlight_#{highlight_column}"]
      end
    end
  end
end
