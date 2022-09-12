# frozen_string_literal: true

module Finders
  class ReportingGroup

    def groups_with_no_commitment(is_public:)
      Group.select('groups.*, count(internship_offers.id) as group_internship_offers_count')
           .group_nature(is_public)
           .joins(join_sources(is_public: is_public))
           .group('groups.id')
           .having('count(internship_offers.id) = 0')
           .order(name: :asc)
    end

    private

    attr_reader :params

    def initialize(params:)
      @params = params
    end

    def join_sources(is_public:)
      internship_offers = InternshipOffer.arel_table
      groups = Group.arel_table

      conditions = internship_offers[:group_id].eq(groups[:id])
      conditions = conditions.and(internship_offers[:is_public]).eq(is_public) unless is_public.nil?
      conditions = conditions.and(internship_offers[:school_track]).eq(params[:school_track]) if school_track_param?
      conditions = conditions.and(groups[:is_public]).eq(is_public) unless is_public.nil?
      conditions = conditions.and(internship_offers[:department]).eq(params[:department]) if department_param?
      if school_year_param?
        conditions = conditions.and(Reporting::InternshipOffer.during_year_predicate(school_year: school_year))
      end

      groups.join(internship_offers, Arel::Nodes::OuterJoin)
            .on(conditions)
            .join_sources
    end

    def department_param?
      params.key?(:department)
    end

    def school_track_param?
      params.key?(:school_track)
    end

    def school_year_param?
      params.key?(:school_year)
    end

    def school_year
      SchoolYear::Floating.new_by_year(year: params[:school_year].to_i)
    end
  end
end
