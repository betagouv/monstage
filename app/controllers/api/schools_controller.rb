# frozen_string_literal: true

module Api
  class SchoolsController < ApiBaseController
    def search
      render_success(object: result, status: 200)
    end

    private
    def result
      []
    end
  end
end
