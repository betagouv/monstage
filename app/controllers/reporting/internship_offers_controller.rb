# frozen_string_literal: true

module Reporting
  class InternshipOffersController < BaseReportingController
    helper_method :dimension_is?, :presenter_for_dimension

    def index
      authorize! :index, Reporting::Acl.new(user: current_user, params: params)

      @offers = current_offers
      respond_to do |format|
        format.xlsx do
          if dimension_is?('offers', params[:dimension])
            @offers = @offers.find_each(batch_size: 1000)
          end
          response.headers['Content-Disposition'] = %(attachment; filename="#{export_filename('offres')}.xlsx")
        end
        format.html do
        end
      end
    end

    private

    def dimension_is?(check, current)
      current = 'sector' if current.nil?
      return true if check == current

      false
    end

    def current_offers
      case params[:dimension]
      when 'offers'
        finder.dimension_offer
      when 'group'
        finder.dimension_by_group
      when 'sector'
        finder.dimension_by_sector
      else
        finder.dimension_by_sector
      end
    end

    def presenter_for_dimension
      case params[:dimension]
      when 'offers'
        Presenters::Reporting::DimensionByOffer
      when 'group'
        Presenters::Reporting::DimensionByGroup
      when 'sector'
        Presenters::Reporting::DimensionBySector
      else
        Presenters::Reporting::DimensionBySector
      end
    end

    def finder
      @finder ||= Finders::ReportingInternshipOffer.new(params: reporting_cross_view_params)
    end
  end
end
