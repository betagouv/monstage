module Reporting
  class SchoolsController < ApplicationController
    def index
      authorize! :index, Reporting::Acl.new(user: current_user, params: params)

      @schools = Finders::ReportingSchool.new(params: params.permit(:department))
                                         .fetch_all
                                         .page(params[:page])
    end
  end
end
