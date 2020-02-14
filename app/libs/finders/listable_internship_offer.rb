# frozen_string_literal: true

module Finders
  # build base query to request internship offers as a linked-list
  class ListableInternshipOffer
    def all
      query_builder.base_query
    end

    def next_from(from:)
      query_builder.base_query
                   .order(id: :desc)
                   .next_from(current: from, column: :id, order: :desc)
                   .limit(1)
                   .first
    end

    def previous_from(from:)
       query_builder.base_query
                    .order(id: :desc)
                    .previous_from(current: from, column: :id, order: :desc)
                    .limit(1)
                    .first
    end

    private
    attr_reader :query_builder

    def initialize(params:, user:)
      @query_builder = UserTypableInternshipOffer.new(params: params, user: user)
    end
  end
end
