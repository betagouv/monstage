# frozen_string_literal: true

module Reporting
  class DashboardsController < BaseReportingController
    # TODO: refactor for understandable widgetization
    def index
      authorize! :index, Acl::Reporting.new(user: current_user, params: params)
      authorize! :see_reporting_dashboard, current_user
      @iframe = metabase_iframe if current_user.is_a? Users::Statistician

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

    def metabase_iframe
      year = params[:school_year].to_i
      payload = {
        resource: { dashboard: 3 },
        params: { 
          "d%C3%A9partement": [params[:department]],
          "ann%C3%A9e_scolaire": "#{year}/#{year+1}" 
        },
        exp: Time.now.to_i + (60 * 10) # 10 minute expiration
      }  
      token = JWT.encode payload, ENV['METABASE_SECRET_KEY']
      iframe_url = ENV['METABASE_SITE_URL'] + "/embed/dashboard/" + token + "#bordered=true&titled=true"
    end
  end
end
