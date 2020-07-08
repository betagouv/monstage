# frozen_string_literal: true

# used in internships#index
module InternshipOffersHelper
  def options_for_groups
    Group.all.map do |group|
      [
        group.name,
        group.id,
        {
          'data-target' => group.is_public? ?
                           'internship-form.groupNamePublic' :
                           'internship-form.groupNamePrivate'
        }
      ]
    end
  end

  def operator_name(internship_offer)
    internship_offer.employer.operator.name
  end

  def forwardable_params
    params.permit(*%i[latitude longitude radius city keyword page filter])
  end

  def back_to_internship_offers_from_internship_offer_path
    default_params = { }

    internship_offers_path(default_params.merge(forwardable_params))
  end

  def listable_internship_offer_path(internship_offer)
    return '' unless internship_offer

    default_params = { id: internship_offer.id }

    internship_offer_path(default_params.merge(forwardable_params))
  end

  def school_type_options_for_default
    '-- Veuillez sélectionner un niveau scolaire --'
  end

  def options_for_school_types
    scholl_tracks_hash_translated = {}
    InternshipOffer.school_types.map do |key, val|
      scholl_tracks_hash_translated[I18n.t("enum.school_types.#{key}")] = val
    end
    scholl_tracks_hash_translated
  end

  def tr_school_type(internship_offer)
    I18n.t("enum.school_types.#{internship_offer.school_type}")
  end
end
