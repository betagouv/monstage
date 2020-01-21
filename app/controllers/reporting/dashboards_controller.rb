module Reporting
  class DashboardsController < BaseReportingController
    # todo refactor for understandable widgetization
    def index
      authorize! :index, Reporting::Acl.new(user: current_user, params: params)

      render locals: {
        # widget left, 0, showing school involvement
        total_schools_with_manager: total_schools_with_manager,
        total_schools_ratio: total_schools_ratio,

        # widget left, 1, showing not invovled schools
        schools_without_manager: school_finder.fetch_all_without_manager,

        # widget left, 2, showing school soon in application
        schools_with_weeks_and_internship: school_finder.fetch_with_weeks_and_internships,

        # widget right, 0, counting internship_offers/applications
        total_internship_offers: internship_offers_finder.total,
        total_approved_applications_count: internship_offers_finder.total_approved_applications_count,

        # widget right, 1, showing distribution public private
        total_internship_offers_is_public: internship_offers_finder.total_is_public,
        total_internship_offers_is_not_public: internship_offers_finder.total_is_not_public,

        # widget right, 2, showing PaQte not involved
        private_groups_not_involved: group_finder.groups_not_involved(is_public: false),
        # widget right, 2, showing public not involved
        public_groups_not_involved: group_finder.groups_not_involved(is_public: true),
      }
    end

    private

    def total_schools_with_manager
      @total_schools_with_manager ||= school_finder.total_with_manager
    end

    def total_schools_ratio
      (total_schools_with_manager.to_f * 100 / school_finder.total).round(2)
    end

    def school_finder
      @school_finder ||= Finders::ReportingSchool.new(params: params.permit(:department))
    end

    def internship_offers_finder
      @internship_offers_finder ||= Finders::ReportingInternshipOffer.new(params: params.permit(:department))
    end

    def group_finder
      @group_finder ||= Finders::ReportingGroup.new(params:params.permit(:department))
    end
  end
end
