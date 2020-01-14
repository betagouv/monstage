module Finders
  class ReportingSchool
    def all_paginated
      base_query.includes(:users, :weeks)
                .order(:name)
                .page(params[:page])
    end

    def fetch_all_without_manager
      base_query.without_school_manager
                .with_teacher_count
                .order(:name)
    end

    private
    attr_reader :params
    def initialize(params:)
      @params = params
    end

    def base_query
      query = Reporting::School.all
      query = query.where(department: params[:department]) if params[:department]
      query
    end
  end
end
