module Api
  class AutocompleteSchool
    def response_wrapper
      {
        match_by_city: {},
        match_by_name: [],
        no_match: result.size.zero?
      }
    end

    def as_json(options={})
      result.inject(response_wrapper) do |accu, school|
        accu[:match_by_city][school.pg_search_highlight_city] = Array(accu[:match_by_city][school.pg_search_highlight_city]).push(school) if school.match_by_city?
        accu[:match_by_name] = accu[:match_by_name].push(school) if school.match_by_name?
        accu
      end
    end

    private
    attr_reader :term, :limit, :result
    def initialize(term:, limit:)
      @term = term
      @limit = limit
      @result = Api::School.autocomplete_by_name_or_city(term: term, limit: limit)
                           .where(visible: true)
                           .includes(:class_rooms)
    end
  end
end

