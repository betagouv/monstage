module Reporting
  class SchoolsController < ApplicationController
    def index
      authorize! :index, Reporting::Acl.new(user: current_user, params: params)

      query = School.all
      query = query.where(department: params[:department]) if params[:department]
      query = query.includes(:users)
      query = query.page(params[:page])
      @schools = query
    end
  end
end
