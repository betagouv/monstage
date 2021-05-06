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


    def partition_internship_offer_created_at_by_month
      query = base_query.merge(Reporting::InternshipOffer.partition_by_month)
      query
    end

    def partition_internship_application_approved_at_by_month
       query = Reporting::InternshipApplication.joins(:internship_offer)
       query = query.where(internship_offers: base_query)
       query = query.where(approved_at: (school_year.beginning_of_period..school_year.end_of_period)) if school_year_param?
       query = query.partition_by_month
       query
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

    def school_year
      @school_year ||= SchoolYear::Floating.new_by_year(year: params[:school_year].to_i)
    end

    def initialize(params:)
      @params = params
    end

  end
end
