# frozen_string_literal: true

module Finders
  class ReportingInternshipOffer

    DETAILED_TYPOLOGY_GROUPS = [
      'private_group',
      'paqte_group',
      'public_group'
    ]
    #
    # raw queries for widgets (reporting/dashboard)
    #
    #
    def total
      base_query.sum('max_candidates')
    end

    #
    # raw queries for stats (reporting/internship_offers)
    #
    def dimension_offer
      base_query.dimension_offer
                .includes(:sector, :weeks, :group, :school, :stats)
    end

    def dimension_by_group
      base_query.dimension_by_group
                .includes(:group, :internship_offer_stats)
    end

    def dimension_by_detailed_typology(detailed_typology:)
      base_query.dimension_by_detailed_typology(detailed_typology: detailed_typology)
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
      query = Reporting::InternshipOffer.all
      query = query.during_year(school_year: school_year) if school_year_param?
      query = query.by_department(department: params[:department]) if department_param?
      query = query.by_group(group_id: params[:group]) if group_param?
      query = query.by_group(group_id: params[:ministries]) if ministries_param?
      query = query.by_academy(academy: params[:academy]) if academy_param?
      query = query.where(is_public: params[:is_public]) if public_param?
      query = query.by_detailed_typology(detailed_typology: params[:dimension]) if detailed_typology?
      query
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

    def detailed_typology?
      params.key?(:dimension) &&
        params[:dimension].in?(DETAILED_TYPOLOGY_GROUPS)
    end

    def department_param?
      params.key?(:department) && !params[:department].nil?
    end

    def group_param?
      params.key?(:group)
    end

    def groups_param?
      params.key?(:groups)
    end

    def ministries_param?
      params.key?(:ministries)
    end

    def academy_param?
      params.key?(:academy)
    end
  end
end
