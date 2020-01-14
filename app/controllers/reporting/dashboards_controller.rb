module Reporting
  class DashboardsController < ApplicationController
    def index
      render locals: {
        total_schools_with_manager: total_schools_with_manager,
        total_schools_ratio: total_schools_ratio,
        schools_without_manager: school_finder.fetch_all_without_manager.limit(10),
        schools_with_weeks_and_internship: school_finder.fetch_with_weeks_and_internships,

        total_internship_offers: internship_offers_finder.total,
        total_approved_applications_count: internship_offers_finder.total_approved_applications_count,
      }
    end

    private

    def total_schools_with_manager
      @total_schools_with_manager ||= school_finder.total_with_manager
    end

    def total_schools_ratio
      (total_schools_with_manager.to_f * 100 / school_finder.total).round(2)
    end

    def school_finder
      @school_finder ||= Finders::ReportingSchool.new(params: params.permit(:department))
    end

    def internship_offers_finder
      @internship_offers_finder ||= Finders::ReportingInternshipOffer.new(params: params.permit(:department))
    end
  end
end
