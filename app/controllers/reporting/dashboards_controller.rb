module Reporting
  class DashboardsController < ApplicationController

    def index
      @total_schools_with_manager = school_base_query.with_school_manager
                                                     .count
      @total_schools_ratio = (@total_schools_with_manager.to_f * 100 / school_base_query.count.to_f).round(2)
      @school_without_manager = Finders::ReportingSchool.new(params: params.permit(:department, :page))
                                                        .fetch_all_without_manager
                                                        .limit(10)
    end

    private

    def school_base_query
      return @school_base_query if @school_base_query
      @school_base_query = Reporting::School.all
      @school_base_query = @school_base_query.where(department: params[:department]) if params[:department]
      @school_base_query
    end
  end
end
