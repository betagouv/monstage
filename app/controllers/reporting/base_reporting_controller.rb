# frozen_string_literal: true

module Reporting
  class BaseReportingController < ApplicationController
    helper_method :reporting_cross_view_params

    private

    def reporting_cross_view_params
      params.permit(:is_public,
                    :department,
                    :academy,
                    :group,
                    :dimension)
    end

    def export_filename(base_name)
      file_name_parts = [base_name]
      if params[:department].present?
        file_name_parts.push(params[:department].parameterize)
      end
      file_name_parts.join('-')
    end
  end
end
