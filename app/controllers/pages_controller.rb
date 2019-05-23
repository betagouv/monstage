class PagesController < ApplicationController
  def statistiques
    if params[:is_public].present? && params[:is_public] == 'true'
      @offers = base_query.grouped_by_group_name
                          .map(&Presenters::InternshipOfferStatsByGroupName.method(:new))
    else
      @offers = base_query.grouped_by_sector
                          .map(&Presenters::InternshipOfferStatsBySector.method(:new))
    end
    if params[:is_public].present?
      @offers_by_publicy = []
    else
      @offers_by_publicy = base_query.grouped_by_publicy
    end

    @departments = InternshipOffer.where.not(department: "").distinct.pluck(:department)
    @groups = InternshipOffer.where.not(group_name: "").distinct.pluck(:group_name)
  end

  private

  def base_query
    base_query = Reporting::InternshipOffer.during_current_year
    base_query = base_query.by_departement(department_name: departement) if departement
    base_query = base_query.by_group_name(group_name: group_name) if group_name
    base_query = base_query.by_academy_name(academy_name: academy_name) if academy_name
    base_query
  end

  def departement
    params[:department]
  end

  def group_name
    params[:group_name]
  end

  def academy_name
    params[:academy_name]
  end
end
