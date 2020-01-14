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
                .with_teacher_count
                .order(:name)
    end

    def fetch_with_weeks_and_internships
      base_query.available_in_the_future
                .group('schools.id')
                .preload(:weeks)
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
