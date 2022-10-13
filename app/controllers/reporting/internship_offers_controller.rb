# frozen_string_literal: true

module Reporting
  class InternshipOffersController < BaseReportingController
    helper_method :dimension_is?, :presenter_for_dimension

    def index
      authorize! :index, Acl::Reporting.new(user: current_user, params: params)

      params.merge!(group: current_user.ministry_id) if current_user.ministry_statistician?

      @offers = current_offers
      @no_offers = no_current_offers
      return if offers_hash[:school_year].blank?

      respond_to do |format|
        format.xlsx do
          response.headers['Content-Disposition'] = %(attachment; filename="#{export_filename('offres')}.xlsx")
          if dimension_is?('offers', params[:dimension])
            SendExportOffersJob.perform_later(current_user, offers_hash)
            redirect_back fallback_location: reporting_dashboards_path(offers_hash),
                          flash: { success: "Votre fichier va vous être envoyé à l'adresse email : #{current_user.email}"}
          else
            render :index_stats
          end
        end
        format.html do
        end
      end
    end

    def employers_offers
      authorize! :index, Acl::Reporting.new(user: current_user, params: params)

      @offers = current_offers
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
      when 'public_group', 'private_group', 'paqte_group'
        finder.dimension_by_detailed_typology(detailed_typology: params[:dimension])
      else # including 'sector'
        finder.dimension_by_sector
      end
    end

    def no_current_offers
      Finders::ReportingGroup.new(params: reporting_cross_view_params)
                             .groups_with_no_commitment(is_public: params[:is_public])
    end

    def presenter_for_dimension
      case params[:dimension]
      when 'offers'
        Presenters::Reporting::DimensionByOffer
      when 'group', 'public_group', 'private_group', 'paqte_group'
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

    def offers_hash(format: :html)
      { department: params[:department],
        school_year: params[:school_year] ,
        format: format}
    end
  end
end
