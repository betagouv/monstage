module Reporting
  class DashboardsController < ApplicationController
    def index
      render locals: {
        total_schools_with_manager: total_schools_with_manager,
        total_schools_ratio: total_schools_ratio,
        schools_without_manager: finder.fetch_all_without_manager.limit(10),
        schools_with_weeks_and_internship: finder.fetch_with_weeks_and_internships
      }
    end

    private

    def total_schools_with_manager
      @total_schools_with_manager ||= finder.total_with_manager
    end

    def total_schools_ratio
      (total_schools_with_manager.to_f * 100 / finder.total).round(2)
    end

    def finder
      @finder ||= Finders::ReportingSchool.new(params: params.permit(:department))
    end
  end
end
