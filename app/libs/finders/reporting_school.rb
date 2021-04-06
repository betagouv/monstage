# frozen_string_literal: true

module Finders
  class ReportingSchool
    def total_with_manager
      base_query.count_with_school_manager
    end

    def total
      base_query.count
    end

    def fetch_all
      base_query.includes(:users, :weeks)
                .order(:name)
    end

    def fetch_all_without_manager
      base_query.without_school_manager
                .order(:name)
    end

    def fetch_all_with_manager
      base_query.with_school_manager
                .order(:name)
    end

    private

    attr_reader :params
    def initialize(params:)
      @params = params
    end

    def base_query
      query = Reporting::School.all
      query = query.with_school_track(params[:school_track])  if params[:school_track]
      query = query.where(visible: true)
      query = query.where(department: params[:department]) if params[:department]
      query = query.joins(:class_rooms)
                   .where('class_rooms.school_track = ?', params[:school_track]) if params[:school_track]
      query
    end
  end
end
