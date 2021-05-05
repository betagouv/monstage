# frozen_string_literal: true

module Reporting
  class DashboardsController < BaseReportingController
    # TODO: refactor for understandable widgetization
    def index
      authorize! :index, Acl::Reporting.new(user: current_user, params: params)

      render locals: {
        count_by_private_sector: dashboard_finder.count_by_private_sector,
        count_by_public_sector: dashboard_finder.count_by_public_sector,
        count_by_association: dashboard_finder.count_by_association,
        grand_total: [],
        partition_internship_offer_created_at_by_month: dashboard_finder.partition_internship_offer_created_at_by_month,
        partition_internship_application_approved_at_by_month: dashboard_finder.partition_internship_application_approved_at_by_month
      }
    end

    private

    def internship_offers_finder
      @internship_offers_finder ||= Finders::ReportingInternshipOffer.new(params: reporting_cross_view_params)
    end

    def group_finder
      @group_finder ||= Finders::ReportingGroup.new(params: reporting_cross_view_params)
    end

    def dashboard_finder
      @dashboard_finder ||= Finders::ReportingDashboard.new(params: reporting_cross_view_params)
    end
  end
end
