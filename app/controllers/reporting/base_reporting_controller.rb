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
                    :ministries,
                    :subscribed_school,
                    :dimension,
                    :detailed_typology,
                    :school_year,
                    :school_id
                  )
    end

    def export_filename(base_name)
      file_name_parts = [base_name]
      file_name_parts.push(params[:department].parameterize) if params[:department].present?
      file_name_parts.join('-')
    end
  end
end
