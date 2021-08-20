# frozen_string_literal: true

module Reporting
  class SchoolsController < BaseReportingController
    helper_method :presenter_for_dimension
    def index
      authorize! :index, Acl::Reporting.new(user: current_user, params: params)
      @schools = Finders::ReportingSchool.new(params: reporting_cross_view_params)
                                         .fetch_all
      respond_to do |format|
        format.xlsx do
          response.headers['Content-Disposition'] = %(attachment; filename="#{export_filename('etablissements')}.xlsx")
        end
        format.html do
          @schools = @schools.page(params[:page])
        end
      end
    end

    private

    def presenter_for_dimension
      Presenters::Reporting::DimensionBySchool
    end
  end
end
