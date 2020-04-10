# frozen_string_literal: true

# used in internships#index
module InternshipOffersHelper
  def current_sector
    return Sector.find(params[:sector_id]) if params[:sector_id]

    nil
  end

  def options_for_groups
    Group.all.map do |group|
      [
        group.name,
        group.id,
        {
          'data-target' => group.is_public? ?
                           'internship-form.groupNamePublic' :
                           'internship-form.groupNamePrivate' }
        ]
    end
  end

  def operator_name(internship_offer)
    internship_offer.employer.operator.name
  end

  def listable_internship_offer_path(internship_offer)
    return "" unless internship_offer

    default_params = { id: internship_offer.id }
    forwardable_params = params.permit(:latitude,
                                       :longitude,
                                       :radius,
                                       :city,
                                       :keyword)

    internship_offer_path(default_params.merge(forwardable_params))
  end
end
