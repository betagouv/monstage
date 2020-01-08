module Reporting
  class InternshipOffersController < ApplicationController
    helper_method :safe_download_params

    def index
      authorize! :index, Reporting::Acl.new(user: current_user, params: params)

      @offers = current_offers
      @offers_by_publicy = public_param.present? ?
                           [] :
                           base_query.grouped_by_publicy
       respond_to do |format|
        format.xlsx do
          response.headers['Content-Disposition'] = 'attachment; filename="my_new_filename.xlsx"'
        end
        format.html
      end
    end

    def safe_download_params
      params.permit(:is_public,
                    :department,
                    :academy,
                    :group)
    end

    private

    def current_offers
      if public_param.present? && public_param == 'true'
        base_query.grouped_by_group
                  .map(&Presenters::InternshipOfferStatsByGroupName.method(:new))
      else
        base_query.grouped_by_sector
                  .map(&Presenters::InternshipOfferStatsBySector.method(:new))
      end
    end

    def base_query
      base_query = Reporting::InternshipOffer.during_current_year
      base_query = base_query.by_department(department: department_param) if department_param
      base_query = base_query.by_group(group: group_param) if group_param
      base_query = base_query.by_academy(academy: academy_param) if academy_param
      base_query = base_query.where(is_public: public_param) if public_param
      base_query
    end

    def public_param
      params[:is_public]
    end

    def department_param
      params[:department]
    end

    def group_param
      params[:group]
    end

    def academy_param
      params[:academy]
    end
  end
end
