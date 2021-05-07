# frozen_string_literal: true
# Finders::ReportingDashboard.new(year: 2020).partition_internship_offer_created_at_by_month
module Finders
  class ReportingDashboard


    def count_by_private_sector
      base_query.select('sum(max_candidates) as total_count, sum(approved_applications_count) as approved_applications_count')
              .where(permalink: nil)
              .where(is_public: false)
              .map(&:attributes)
              .first
    end

    def count_by_public_sector
      base_query.select('sum(max_candidates) as total_count, sum(approved_applications_count) as approved_applications_count')
                .where(permalink: nil)
                .where(is_public: true)
                .map(&:attributes)
                .first
    end

    def count_by_association
      base_query.select('sum(max_candidates) as total_count, sum(approved_applications_count) as approved_applications_count')
                .merge(InternshipOffer.from_api)
                .map(&:attributes)
                .first
    end

    # conditions = conditions.and(internship_offers[:is_public].eq(true))
    def partition_internship_offer_created_at_by_month
      months = Month.arel_table
      internship_offers = InternshipOffer.arel_table

      conditions = date_trunc('month', internship_offers[:created_at]).eq(months[:date])
      # conditions = Reporting::InternshipOffer.during_year_predicate(school_year: school_year)
      conditions = conditions.and(internship_offers[:department].eq(params[:department])) if department_param?
      join_sources = months.join(internship_offers, Arel::Nodes::OuterJoin).on(conditions).join_sources

      query = Month.select("months.date AS date, sum(internship_offers.max_candidates) AS COUNT")
      query = query.where(date: school_year.range) if school_year_param?
      query = query.joins(join_sources)
      query = query.group(:date)
      query = query.order(:date)
      query.map(&:attributes)
    end

    def date_trunc(by, attribute)
      Arel::Nodes::NamedFunction.new(
        'DATE_TRUNC', [Arel.sql("'#{by}'"), attribute]
      )
    end

    def partition_internship_application_approved_at_by_month
       months = Month.arel_table
       internship_applications = InternshipApplication.arel_table
       subquery = subq.as("internship_applications")
       month_conditions = date_trunc('month', subquery[:approved_at]).eq(months[:date])

       join_sources = months.join(subquery, Arel::Nodes::OuterJoin).on(month_conditions)
                            .join_sources
       # "months.date AS date, count(internship_applications.id) AS COUNT"
       query = Month.select(months[:date].as("date"), subquery[:id].count.as('count'))
       query = query.where(date: school_year.range) if school_year_param?
       query = query.joins(join_sources)
       query = query.group(:date)
       query = query.order(:date)
       query.map(&:attributes)
    end

    def subq
      internship_offers = InternshipOffer.arel_table
      internship_applications = InternshipApplication.arel_table

      internship_offer_conditions = internship_offers[:id].eq(internship_applications[:internship_offer_id])
      internship_offer_conditions = internship_offer_conditions.and(internship_offers[:department].eq(params[:department])) if department_param?
      internship_applications.project(internship_applications[:id], internship_applications[:approved_at])
                             .join(internship_offers, Arel::Nodes::InnerJoin)
                             .on(internship_offer_conditions)
    end

    def school_year
      @school_year ||= SchoolYear::Floating.new_by_year(year: params[:school_year].to_i)
    end

    private

    attr_reader :params

    def base_query
      query = Reporting::InternshipOffer.all
      query = query.during_year(school_year: school_year) if school_year_param?
      query = query.by_department(department: params[:department]) if department_param?

      query
    end

    def department_param?
      params.key?(:department)
    end

    def school_year_param?
      params.key?(:school_year)
    end

    def initialize(params:)
      @params = params
    end

  end
end
