class PagesController < ApplicationController
  def statistiques
    @offers_by_sector = base_query.grouped_by_sector
    @offers_by_publicy = base_query.grouped_by_publicy
    @departments = InternshipOffer.pluck(:department).uniq.reject(&:blank?)
    @groups = InternshipOffer.pluck(:group_name).uniq.reject(&:blank?)
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
