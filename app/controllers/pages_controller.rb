# frozen_string_literal: true

class PagesController < ApplicationController
  def statistiques
    if params[:is_public].present? && params[:is_public] == 'true'
      @offers = base_query.grouped_by_group
                          .map(&Presenters::InternshipOfferStatsByGroupName.method(:new))
    else
      @offers = base_query.grouped_by_sector
                          .map(&Presenters::InternshipOfferStatsBySector.method(:new))
    end
    @offers_by_publicy = if params[:is_public].present?
                           []
                         else
                           base_query.grouped_by_publicy
                         end
  end

  private

  def base_query
    base_query = Reporting::InternshipOffer.during_current_year
    base_query = base_query.by_departement(department: departement) if departement
    base_query = base_query.by_group(group: group) if group
    base_query = base_query.by_academy(academy: academy) if academy
    base_query
  end

  def departement
    params[:department]
  end

  def group
    params[:group]
  end

  def academy
    params[:academy]
  end
end
