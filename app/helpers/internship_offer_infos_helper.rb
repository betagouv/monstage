# frozen_string_literal: true

# used in internships#index
module InternshipOfferInfosHelper
  def preselect_all_weeks?(object)
    is_new_record = object.new_record?
    is_preselectable_entity = object.is_a?(InternshipOfferInfos::WeeklyFramedInfo) || object.is_a?(InternshipOfferInfo) || object.is_a?(InternshipOffers::WeeklyFramed)
    is_new_record && is_preselectable_entity
  end

  def internship_offer_info_type_options_for_default
    '-- Veuillez sélectionner un niveau scolaire --'
  end

  def tr_school_prefix
    'activerecord.attributes.internship_offer_info.internship_type'
  end

  def options_for_internship_info_type
    [
      [I18n.t("#{tr_school_prefix}.middle_school"), 'InternshipOfferInfos::WeeklyFramedInfo'],
      [I18n.t("#{tr_school_prefix}.high_school"), 'InternshipOfferInfos::FreeDateInfo']
    ]
  end

  def tr_school_type(internship_offer_info)
    case internship_offer_info.class.name
    when 'InternshipOfferInfos::WeeklyFramedInfo' then I18n.t("#{tr_school_prefix}.middle_school")
    when 'InternshipOfferInfos::FreeDateInfo' then I18n.t("#{tr_school_prefix}.high_school")
    else I18n.t("#{tr_school_prefix}.middle_school")
    end
  end
end
