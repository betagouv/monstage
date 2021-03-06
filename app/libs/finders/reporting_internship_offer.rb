# frozen_string_literal: true

module Finders
  class ReportingInternshipOffer
    #
    # raw queries for widgets (reporting/dashboard)
    #
    # TODO/1/start/groupable in one query
    def total
      base_query.sum('max_candidates')
    end

    def total_approved_applications_count
      base_query.sum('approved_applications_count')
    end

    def total_is_public
      base_query.where(is_public: true)
                .sum('max_candidates')
    end

    def total_is_not_public
      base_query.where(is_public: false)
                .sum('max_candidates')
    end
    # TODO/1/end/groupable in one query

    #
    # raw queries for stats (reporting/internship_offers)
    #
    def dimension_offer
      base_query.dimension_offer
                .includes(:sector, :weeks, :group, :school)
    end

    def dimension_by_group
      base_query.dimension_by_group
                .includes(:group)
    end

    def dimension_by_sector
      base_query.dimension_by_sector
                .includes(:sector)
    end

    private

    attr_reader :params

    def initialize(params:)
      @params = params
    end

    def base_query
      base_query = Reporting::InternshipOffer.all
      base_query = base_query.during_year(school_year: school_year) if school_year_param?
      base_query = base_query.by_department(department: params[:department]) if department_param?
      base_query = base_query.by_school_track(school_track: school_track) if school_track
      base_query = base_query.by_group(group: params[:group]) if group_param?
      base_query = base_query.by_academy(academy: params[:academy]) if academy_param?
      base_query = base_query.where(is_public: params[:is_public]) if public_param?
      base_query
    end

    def school_year
      SchoolYear::Floating.new_by_year(year: params[:school_year].to_i)
    end

    def school_year_param?
      params.key?(:school_year)
    end

    def public_param?
      params.key?(:is_public)
    end

    def department_param?
      params.key?(:department)
    end

    def group_param?
      params.key?(:group)
    end

    def academy_param?
      params.key?(:academy)
    end

    def school_track
      params[:school_track]
    end
  end
end
