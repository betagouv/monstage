module Reporting
  class SchoolsController < ApplicationController
    def index
      authorize! :index, Reporting::Acl.new(user: current_user, params: params)

      @schools = Finders::ReportingSchool.new(params: params.permit(:department, :page))
                                         .all_paginated
    end
  end
end
