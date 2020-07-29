# frozen_string_literal: true

# used in internships#index
module InternshipOfferInfosHelper
  def preselect_all_weeks?(object)
    is_new_record = object.new_record?
    is_preselectable_entity = object.is_a?(InternshipOfferInfos::WeeklyFramed) || object.is_a?(InternshipOfferInfo)
    is_new_record && is_preselectable_entity
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

  def operator_name(internship_offer_info)
    internship_offer_info.employer.operator.name
  end

  def forwardable_params
    params.permit(
      :latitude, :longitude, :radius, :city, :keyword, :page, :filter, :school_type
    )
  end

  def back_to_internship_offer_infos_from_internship_offer_info_path
    default_params = {}

    internship_offer_infos_path(default_params.merge(forwardable_params))
  end

  def listable_internship_offer_info_path(internship_offer_info)
    return '' unless internship_offer_info

    default_params = { id: internship_offer_info.id }

    internship_offer_info_path(default_params.merge(forwardable_params))
  end

  def stepper_step_2_completed?(internship_offer_info)
    internship_offer_info.try(:aasm_state) == 'step_3'
  end
  
  def internship_offer_info_type_options_for_default
    '-- Veuillez sélectionner un niveau scolaire --'
  end

  def tr_school_prefix
    'activerecord.attributes.internship_offer_info.internship_type'
  end

  def options_for_internship_info_type
    [
      [I18n.t("#{tr_school_prefix}.middle_school"), 'InternshipOfferInfos::WeeklyFramed'],
      [I18n.t("#{tr_school_prefix}.high_school"), 'InternshipOfferInfos::FreeDate']
    ]
  end

  def tr_school_type(internship_offer_info)
    case internship_offer_info.class.name
    when 'InternshipOfferInfos::WeeklyFramed' then I18n.t("#{tr_school_prefix}.middle_school")
    when 'InternshipOfferInfos::FreeDate' then I18n.t("#{tr_school_prefix}.high_school")
    else I18n.t("#{tr_school_prefix}.middle_school")
    end
  end
end
