module Reporting
  class SchoolsController < BaseReportingController
    def index
      authorize! :index, Reporting::Acl.new(user: current_user, params: params)

      @schools = Finders::ReportingSchool.new(params: reporting_cross_view_params)
                                         .fetch_all
                                         .page(params[:page])
    end
  end
end
