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
        if school.match_by_city?(term)
          accu[:match_by_city][school.pg_search_highlight_city] = append_result(
            list: accu[:match_by_city][school.pg_search_highlight_city],
            item: school,
            sort_by: :name
          )
        else
          accu[:match_by_name] = append_result(list: accu[:match_by_name],
                                               item: school,
                                               sort_by: :zipcode)
        end
        accu
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

    def append_result(list:, item:, sort_by:)
      Array(list).push(item).sort_by(&sort_by)
    end
  end
end

