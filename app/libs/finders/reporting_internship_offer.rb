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
      base_query = Reporting::InternshipOffer.during_current_year
      base_query = base_query.by_department(department: department_param) if department_param
      base_query = base_query.by_group(group: group_param) if group_param
      base_query = base_query.by_academy(academy: academy_param) if academy_param
      base_query = base_query.by_school_track(school_track: school_track) if school_track
      base_query = base_query.where(is_public: public_param) if public_param
      base_query
    end

    def public_param
      params[:is_public]
    end

    def department_param
      params[:department]
    end

    def group_param
      params[:group]
    end

    def academy_param
      params[:academy]
    end

    def school_track
      params[:school_track]
    end
  end
end
