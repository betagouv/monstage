module Reporting
  class InternshipOffersController < ApplicationController
    helper_method :safe_download_params

    def index
      @offers = current_offers
      @offers_by_publicy = is_public.present? ?
                           [] :
                           base_query.grouped_by_publicy
    end

    def download
      headers = Reporting::InternshipOffer.csv_headers(headers: {report_row_title: ""})
      converter = Dto::ActiveRecordToCsv.new(entries: current_offers,
                                             headers: headers)
      send_data(converter.to_csv,
                type: 'text/csv',
                disposition: 'attachment',
                filename: 'monstagedetroisieme-export.csv')
    end

    def safe_download_params
      params.permit(:is_public,
                    :department,
                    :academy,
                    :group)
    end

    private

    def current_offers
      if is_public.present? && is_public == 'true'
        base_query.grouped_by_group
                  .map(&Presenters::InternshipOfferStatsByGroupName.method(:new))
      else
        base_query.grouped_by_sector
                  .map(&Presenters::InternshipOfferStatsBySector.method(:new))
      end
    end

    def base_query
      base_query = Reporting::InternshipOffer.during_current_year
      base_query = base_query.by_department(department: department) if department
      base_query = base_query.by_group(group: group) if group
      base_query = base_query.by_academy(academy: academy) if academy
      base_query
    end

    def is_public
      params[:is_public]
    end

    def department
      params[:department]
    end

    def group
      params[:group]
    end

    def academy
      params[:academy]
    end
  end
end
