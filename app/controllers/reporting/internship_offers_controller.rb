module Reporting
  class InternshipOffersController < ApplicationController
    helper_method :reporting_internship_offers_params

    def index
      authorize! :index, Reporting::Acl.new(user: current_user, params: params)

      @offers = current_offers
      @offers_by_publicy = params[:is_public].present? ?
                           [] :
                           finder.grouped_by_publicy
       respond_to do |format|
        format.xlsx do
          response.headers['Content-Disposition'] = 'attachment; filename="my_new_filename.xlsx"'
        end
        format.html
      end
    end

    private
    def reporting_internship_offers_params
      params.permit(:is_public,
                    :department,
                    :academy,
                    :group)
    end

    # @note : this one is fucked up ; should be case when etc.. based on a flag
    def current_offers
      if params[:is_public].present? && params[:is_public] == 'true'
        finder.grouped_by_group
              .map(&Presenters::InternshipOfferStatsByGroupName.method(:new))
      else
        finder.grouped_by_sector
              .map(&Presenters::InternshipOfferStatsBySector.method(:new))
      end
    end

    def finder
      @finder ||= Finders::ReportingInternshipOffer.new(params: reporting_internship_offers_params)
    end
  end
end
