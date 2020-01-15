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
  end
end
