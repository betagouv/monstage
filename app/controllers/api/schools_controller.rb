# frozen_string_literal: true

module Api
  # Search school by city
  class SchoolsController < ApiBaseController
    def search
      render_success(
        object: result,
        status: 200,
        json_options: {
          methods: %i[pg_search_highlight_city pg_search_highlight_name]
        }
      )
    end

    def nearby
      render_success(
        object: School.nearby(latitude: params[:latitude], longitude: params[:longitude], radius: 60_000),
        status: 200,
        json_options: {
          methods: %i[weeks]
        }
      )
    end

    private

    def result
      Api::AutocompleteSchool.new(term: params[:query], limit: 25)
    end
  end
end
