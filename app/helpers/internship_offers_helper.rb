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
end
