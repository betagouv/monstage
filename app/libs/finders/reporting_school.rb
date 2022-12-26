# frozen_string_literal: true

module Finders
  class ReportingSchool
    ALL = 'all'

    def total
      base_query.count
    end

    def fetch_all
      base_query.includes(:users, :weeks)
                .order(:name)
    end

    private

    attr_reader :params
    def initialize(params:)
      @params = params
    end

    def base_query
      query = Reporting::School.all
      query = query.where(visible: true)
      query = query.where(department: params[:department]) if department_param?
      query = query.where(id: params[:school_id]) if specific_school?
      query = query.by_subscribed_school(subscribed_school: params[:subscribed_school]) if subscribed_school_param?
      query
    end

    def department_param?
      params.key?(:department)
    end

    def specific_school?
      params.key?(:school_id)
    end

    def subscribed_school_param?
      params.key?(:subscribed_school) && params[:subscribed_school] != ALL
    end
  end
end
