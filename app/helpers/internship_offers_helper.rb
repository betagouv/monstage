# frozen_string_literal: true

# used in internships#index
module InternshipOffersHelper
  def preselect_all_weeks?(object)
    is_new_record = object.new_record?
    is_preselectable_entity = object.is_a?(InternshipOffers::WeeklyFramed) || object.is_a?(InternshipOffer)
    is_new_record && is_preselectable_entity
  end

  def internship_offer_application_path(object)
    return object.permalink if object.from_api?
    return listable_internship_offer_path(object, anchor: 'internship-application-form')
  end

  def internship_offer_application_html_opts(object, opts)
    opts = opts.merge({title: 'Voir l\'offre en détail'})
    opts = opts.merge({title: 'Voir l\'offre en détail (nouvelle fenêtre)', target: '_blank', rel: 'external noopener noreferrer'}) if object.from_api?
    opts
  end

  def options_for_groups
    Group.all.map do |group|
      [
        group.name,
        group.id,
        {
          'data-target' => if group.is_public?
                             'internship-form.groupNamePublic'
                           else
                             'internship-form.groupNamePrivate'
                           end
        }
      ]
    end
  end

  def operator_name(internship_offer)
    internship_offer.employer.operator.name
  end

  def forwardable_params
    params.permit(
      :latitude, :longitude, :radius, :city, :keyword, :page, :filter, :school_type
    )
  end

  def back_to_internship_offers_from_internship_offer_path
    default_params = {}

    internship_offers_path(default_params.merge(forwardable_params))
  end

  def listable_internship_offer_path(internship_offer, options = {})
    return '' unless internship_offer

    default_params = options.merge(id: internship_offer.id)

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
end
