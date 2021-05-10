# frozen_string_literal: true

module Reporting
  class InternshipOffersController < BaseReportingController
    helper_method :dimension_is?, :presenter_for_dimension

    def index
      authorize! :index, Acl::Reporting.new(user: current_user, params: params)

      @offers = current_offers
      respond_to do |format|
        format.xlsx do
          @offers = @offers.find_each(batch_size: 1000) if dimension_is?('offers', params[:dimension])
          response.headers['Content-Disposition'] = %(attachment; filename="#{export_filename('offres')}.xlsx")
        end
        format.html do
        end
      end
    end

    def employers_offers
      index
    end

    private

    def dimension_is?(check, current)
      current ||= 'sector'
      check == current
    end

    def current_offers
      case params[:dimension]
      when 'offers'
        finder.dimension_offer
      when 'group'
        finder.dimension_by_group
      when 'entreprise'
        finder.dimension_by_entreprise
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
      when 'entreprise'
        Presenters::Reporting::DimensionByEntreprise
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
