module Api
  class AutocompleteSchool
    def as_json(options={})
      result.inject({}) do |accu, school|
        accu[school.city] = Array(accu[school.city]).push(school)
        accu
      end
    end

    private
    attr_reader :term, :limit, :result
    def initialize(term:, limit:)
      @term = term
      @limit = limit
      @result = Api::School.autocomplete_by_city(term: term, limit: limit)
    end
  end
end

