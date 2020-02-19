# frozen_string_literal: true

module Api
  class AutocompleteSchool
    def response_wrapper
      {
        match_by_city: {},
        match_by_name: [],
        no_match: result.size.zero?
      }
    end

    def as_json(_options = {})
      result.each_with_object(response_wrapper) do |school, accu|
        if school.match_by_city?(term)
          accu[:match_by_city][school.pg_search_highlight_city] = Array(accu[:match_by_city][school.pg_search_highlight_city]).push(school)
        end
        unless school.match_by_city?(term)
          accu[:match_by_name] = accu[:match_by_name].push(school)
        end
      end
    end

    private

    attr_reader :term, :limit, :result
    def initialize(term:, limit:)
      @term = term
      @limit = limit
      @result = Api::School.autocomplete_by_name_or_city(term: term)
                           .where(visible: true)
                           .includes(:class_rooms)
                           .limit(limit)
    end
  end
end
