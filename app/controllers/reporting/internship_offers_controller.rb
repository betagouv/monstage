module Reporting
  class InternshipOffersController < ApplicationController
    helper_method :reporting_internship_offers_params,
                  :dimension_is?

    def index
      authorize! :index, Reporting::Acl.new(user: current_user, params: params)

      @offers = current_offers
      respond_to do |format|
        format.xlsx do
          response.headers['Content-Disposition'] = 'attachment; filename="my_new_filename.xlsx"'
        end
        format.html
      end
    end

    private

    def dimension_is?(check, current)
      current = 'sector' if current.nil?
      return true if check == current
      return false
    end

    def reporting_internship_offers_params
      params.permit(:is_public,
                    :department,
                    :academy,
                    :group)
    end

    # @note : this one is fucked up ; should be case when etc.. based on a flag
    def current_offers
      case params[:dimension]
      when 'group'
        finder.dimension_by_group
              .map(&Presenters::InternshipOfferStatsByGroupName.method(:new))
      when 'sector', nil
        finder.dimension_by_sector
              .map(&Presenters::InternshipOfferStatsBySector.method(:new))
      end
    end

    def finder
      @finder ||= Finders::ReportingInternshipOffer.new(params: reporting_internship_offers_params)
    end
  end
end
