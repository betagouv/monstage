# frozen_string_literal: true

module Api
  # Search school by city
  class SchoolsController < ApiBaseController
    def search
      render_success(object: result, status: 200)
    end

    private

    def result
      Api::AutocompleteSchool.new(term: params[:query], limit: 25)
    end
  end
end
