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
      # Following sort by puts at the end those with 
      # attribute nil that would otherwise generate an error
      Array(list).push(item)
                 .sort_by do |ite| 
                    [ite.send(sort_by) ? 0 : 1 , ite.send(sort_by)]
                 end
    end
  end
end
