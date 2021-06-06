# frozen_string_literal: true

module Reporting
  class DashboardsController < BaseReportingController
    # TODO: refactor for understandable widgetization
    def index
      authorize! :index, Acl::Reporting.new(user: current_user, params: params)

      render locals: { dashboard_finder: dashboard_finder }
    end

    def import_data
      @user = current_user
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
