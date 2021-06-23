# frozen_string_literal: true

module Reporting
  class DashboardsController < BaseReportingController
    # TODO: refactor for understandable widgetization
    def index
      authorize! :index, Acl::Reporting.new(user: current_user, params: params)
      authorize! :see_reporting_dashboard, current_user

      render locals: { dashboard_finder: dashboard_finder }
    end

    def refresh
      Airtable::BaseSynchronizer.new.pull_all

      redirect_to redirect_back_with_anchor_to_stats, flash: { success: 'Les statistiques seront rafraichies dans 5 minutes.' }
    end

    def import_data
      @user = current_user
    end

    private

    # inspired by : https://github.com/rails/rails/blob/75ac626c4e21129d8296d4206a1960563cc3d4aa/actionpack/lib/action_controller/metal/redirecting.rb#L90
    def redirect_back_with_anchor_to_stats
      redirect_url = [ request.headers["Referer"], current_user.custom_dashboard_path].compact.first
      uri = URI.parse(redirect_url)
      uri.fragment = "operator-stats"
      uri.to_s
    end

    def internship_offers_finder
      @internship_offers_finder ||= Finders::ReportingInternshipOffer.new(params: reporting_cross_view_params)
    end

    def group_finder
      @group_finder ||= Finders::ReportingGroup.new(params: reporting_cross_view_params)
    end

    def dashboard_finder
      @dashboard_finder ||= Finders::ReportingDashboard.new(params: reporting_cross_view_params, user: current_user)
    end
  end
end
