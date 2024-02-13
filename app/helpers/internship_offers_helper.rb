# frozen_string_literal: true

# used in internships#index
module InternshipOffersHelper
  def preselect_all_weeks?(object)
    return false unless object.try(:new_record?)

    is_preselectable_entity = [
      InternshipOfferInfo,
      InternshipOffer,
      InternshipOffers::WeeklyFramed,
      HostingInfo
    ]
    is_preselectable_entity.any?{ |klass| object.is_a?(klass) }
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
          'data-organisation-form-target' => if group.is_public?
                                              'groupNamePublic'
                                             else
                                               'groupNamePrivate'
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
      :latitude,
      :longitude,
      :radius,
      :city,
      :keyword,
      :page,
      :filter,
      :school_year,
      :order,
      :direction,
      week_ids: [],
    )
  end

  def back_to_internship_offers_from_internship_offer_path(current_user, url)
    if url.include?('dashboard') && [Users::Employer, Users::Operator, Users::PrefectureStatistician].include?(current_user.class)
      return dashboard_internship_offers_path
    end

    default_params = {}

    internship_offers_path(default_params.merge(forwardable_params))
  end

  def listable_internship_offer_path(internship_offer, options = {})
    return '' unless internship_offer

    default_params = options.merge(id: internship_offer.id)

    internship_offer_path(default_params.merge(forwardable_params))
  end

  def select_weekly_start(internship_offer)
    internship_offer.weekly_planning? ? internship_offer.weekly_hours.try(:first) || '09:00' : '--'
  end

  def select_weekly_end(internship_offer)
    internship_offer.weekly_planning? ? internship_offer.weekly_hours.try(:last) || '17:00' : '--'
  end

  def select_daily_start(internship_offer, day)
    internship_offer.daily_hours.blank? ? '' : internship_offer.daily_hours&.fetch(day, '09:00')
  end

  def select_daily_end(internship_offer, day)
    internship_offer.daily_hours.blank? ? '' : internship_offer.daily_hours&.fetch(day, '17:00')
  end

  def truncate_description(internship_offer)
    description = internship_offer.description_rich_text.to_s.present? ? internship_offer.description_rich_text.to_plain_text : internship_offer.description
    description.truncate(280, separator: ' ')
  end
end
