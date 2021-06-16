# frozen_string_literal: true
module Finders
  class ReportingDashboard


    def count_by_private_sector
      base_query.select('sum(max_candidates) as total_count, sum(approved_applications_count) as approved_applications_count')
              .where(permalink: nil)
              .where(is_public: false)
              .map(&:attributes)
              .first
    end

    def count_by_private_sector_pacte
      base_query.select('sum(max_candidates) as total_count, sum(approved_applications_count) as approved_applications_count')
              .where(permalink: nil)
              .joins(:group)
              .where(group: {is_pacte: false})
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


    # SELECT months.date AS date, count(internship_applications.id) AS COUNT FROM "months"
    #   LEFT OUTER JOIN (
    #     SELECT "internship_applications"."id", "internship_applications"."approved_at" FROM "internship_applications"
    #       INNER JOIN "internship_offers" ON "internship_offers"."id" = "internship_applications"."internship_offer_id" AND "internship_offers"."department" = 'Seine-Saint-Denis'
    #     ) as internship_applications
    #     ON DATE_TRUNC('month', "internship_applications"."approved_at") = "months"."date"
    # WHERE "months"."date" BETWEEN '2019-09-01' AND '2020-09-01'
    # GROUP BY "months"."date" ORDER BY "months"."date" ASC
    def internship_offer_created_at_by_month
      months = Month.arel_table
      internship_offers = InternshipOffer.arel_table

      conditions = date_trunc('month', internship_offers[:created_at]).eq(months[:date])
      conditions = conditions.and(internship_offers[:department].eq(params[:department])) if department_param?
      join_sources = months.join(internship_offers, Arel::Nodes::OuterJoin).on(conditions).join_sources

      query = Month.select("months.date AS date, sum(internship_offers.max_candidates) AS COUNT")
      if school_year_param?
        query = query.where(date: school_year.range)
      else
        range = (
          SchoolYear::Floating.new(date: Date.new(2019, 9,1)).beginning_of_period
          ..
          SchoolYear::Current.new.end_of_period
        )
        query = query.where(date: range)
      end
      query = query.joins(join_sources)
      query = query.group(:date)
      query = query.order(:date)
      query.map(&:attributes)
    end

    # SELECT "months"."date" AS date,
    #    COUNT(bim."id") AS COUNT
    # FROM "months"
    # LEFT OUTER JOIN
    #   (SELECT "internship_applications"."id",
    #           "internship_applications"."approved_at"
    #    FROM "internship_applications"
    #    INNER JOIN "internship_offers" ON "internship_offers"."id" = "internship_applications"."internship_offer_id"
    #    AND "internship_offers"."department" = 'Seine-Saint-Denis'
    #    AND "internship_applications"."aasm_state" = 'approved') bim ON DATE_TRUNC('month', bim."approved_at") = "months"."date"
    # WHERE "months"."date" BETWEEN '2020-09-01' AND '2021-09-01'
    # GROUP BY "months"."date"
    # ORDER BY "months"."date" ASC
    def internship_application_approved_at_month
      months = Month.arel_table
      internship_applications = InternshipApplication.arel_table
      subquery = subq.as("bim")
      month_conditions = date_trunc('month', subquery[:approved_at]).eq(months[:date])

      join_sources = months.join(subquery, Arel::Nodes::OuterJoin).on(month_conditions)
                            .join_sources
      query = Month.select(months[:date].as("date"), subquery[:id].count.as('count'))
      if school_year_param?
        query = query.where(date: school_year.range)
      else
        range = (
          SchoolYear::Floating.new(date: Date.new(2019, 9,1)).beginning_of_period
          ..
          SchoolYear::Current.new.end_of_period
        )
        query = query.where(date: range)
      end

      query = query.joins(join_sources)
      query = query.group(:date)
      query = query.order(:date)
      Rails.logger.info query.to_sql
      query.map(&:attributes)
    end

    def subq
      internship_offers = InternshipOffer.arel_table
      internship_applications = InternshipApplication.arel_table

      conditions = internship_offers[:id].eq(internship_applications[:internship_offer_id])
      conditions = conditions.and(internship_offers[:department].eq(params[:department])) if department_param?
      conditions = conditions.and(internship_applications[:aasm_state].eq(:approved))
      internship_applications.project(internship_applications[:id], internship_applications[:approved_at])
                             .join(internship_offers, Arel::Nodes::InnerJoin)
                             .on(conditions)
    end

    def school_year
      @school_year ||= SchoolYear::Floating.new_by_year(year: params[:school_year].to_i)
    end

    private

    attr_reader :params, :user

    def base_query
      query = Reporting::InternshipOffer.all
      query = query.during_year(school_year: school_year) if school_year_param?
      query = query.limited_to_ministry(user: user) if user.ministry_statistician?
      query = query.by_department(department: params[:department]) if department_param?

      query
    end

    def department_param?
      params.key?(:department)
    end

    def school_year_param?
      params.key?(:school_year)
    end

    def initialize(params:, user: )
      @params = params
      @user = user
    end


    def date_trunc(by, attribute)
      Arel::Nodes::NamedFunction.new(
        'DATE_TRUNC', [Arel.sql("'#{by}'"), attribute]
      )
    end


  end
end
