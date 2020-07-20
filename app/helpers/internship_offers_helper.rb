# frozen_string_literal: true

# used in internships#index
module InternshipOffersHelper
  def preselect_all_weeks?(object)
    is_new_record = object.new_record?
    is_preselectable_entity = object.is_a?(InternshipOffers::WeeklyFramed) || object.is_a?(InternshipOffer)
    is_new_record && is_preselectable_entity
  end

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
    params.permit(
      *%i[latitude longitude radius city keyword page filter school_type]
    )
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

  def internship_offer_type_options_for_default
    '-- Veuillez sélectionner un niveau scolaire --'
  end

  def tr_school_prefix
    'activerecord.attributes.internship_offer.internship_type'
  end

  def options_for_internship_type
    [
      [I18n.t("#{tr_school_prefix}.middle_school"), 'InternshipOffers::WeeklyFramed'],
      [I18n.t("#{tr_school_prefix}.high_school"), 'InternshipOffers::FreeDate']
    ]
  end

  def tr_school_type(internship_offer)
    case internship_offer.class.name
    when 'InternshipOffers::WeeklyFramed' then return I18n.t("#{tr_school_prefix}.middle_school")
    when 'InternshipOffers::FreeDate' then return I18n.t("#{tr_school_prefix}.high_school")
    else return I18n.t("#{tr_school_prefix}.middle_school")
    end
  end
end
