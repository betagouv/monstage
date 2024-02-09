# frozen_string_literal: true

module Finders
  # build base query to request internship offers as a linked-list
  class ListableInternshipOffer
    def all
      finder.base_query
    end

    def next_from(from:)
      finder.base_query
            .next_from(current: from, column: :id, order: :desc)
            .limit(1)
            .first
    end

    def previous_from(from:)
      finder.base_query
            .previous_from(current: from, column: :id, order: :desc)
            .limit(1)
            .first
    end

    def all_without_page
      finder.base_query_without_page
    end

    private

    attr_reader :finder

    def initialize(finder:)
      @finder = finder
    end
  end
end
