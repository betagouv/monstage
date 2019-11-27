# frozen_string_literal: true

# used in internships#index
module InternshipOffersHelper
  def current_sector
    return Sector.find(params[:sector_id]) if params[:sector_id]

    nil
  end

  def options_for_groups
    Group::PUBLIC.map { |admin| [admin, { 'data-target' => 'internship-form.groupNamePublic' }] } +
      Group::PRIVATE.map { |admin| [admin, { 'data-target' => 'internship-form.groupNamePrivate' }] }
  end

  def operator_name(internship_offer)
    internship_offer.employer.operator.name
  end

  def listable_internship_offer_path(internship_offer)
    return "" unless internship_offer

    default_params = { id: internship_offer.id }
    forwardable_params = params.permit(:sector_id, :latitude, :longitude)

    internship_offer_path(default_params.merge(forwardable_params))
  end
end
