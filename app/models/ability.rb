# frozen_string_literal: true

# list abilities for users
class Ability
  include CanCan::Ability

  def initialize(user = nil)
    if user.present?
      case user.type
      when 'Users::Student' then student_abilities(user: user)
      when 'Users::Employer' then employer_abilities(user: user)
      when 'Users::God' then god_abilities
      when 'Users::Operator' then operator_abilities(user: user)
      when 'Users::PrefectureStatistician' then statistician_abilities(user: user)
      when 'Users::EducationStatistician' then education_statistician_abilities(user: user)
      when 'Users::MinistryStatistician' then ministry_statistician_abilities(user: user)
      when 'Users::SchoolManagement'
        common_school_management_abilities(user: user)
        school_manager_abilities(user: user) if user.school_manager?
        admin_officer_abilities(user: user) if user.admin_officer?
      end

      shared_signed_in_user_abilities(user: user)
    else
      visitor_abilities
    end
  end

  def visitor_abilities
    can %i[read apply], InternshipOffer
  end

  def god_abilities
    can :show, :account
    can :manage, School
    can :manage, Sector
    can %i[destroy see_tutor], InternshipOffer
    can %i[read update export unpublish publish], InternshipOffer
    can %i[read update destroy export], InternshipApplication
    can :manage, InternshipOfferKeyword
    can :manage, Group
    can :access, :rails_admin   # grant access to rails_admin
    can %i[read update delete discard export], InternshipOffers::Api
    can :read, :dashboard       # grant access to the dashboard
    can :read, :kpi # grant access to the dashboard
    can %i[index department_filter], Acl::Reporting do |_acl|
      true
    end
    can %i[index_and_filter], Reporting::InternshipOffer
    can :manage, InternshipAgreement
    can %i[ switch_user
            read
            update
            destroy
            export
            export_reporting_dashboard_data
            see_reporting_dashboard
            see_reporting_internship_offers
            see_reporting_schools
            see_reporting_associations
            see_reporting_enterprises
            see_dashboard_enterprises_summary
            see_dashboard_administrations_summary
            see_dashboard_associations_summary], User
    can :manage, Operator
    can :see_minister_video, User
  end

  def student_abilities(user:)
    can :look_for_offers, User
    can :show, :account
    can :change, ClassRoom do |class_room|
      class_room.school_id == user.school_id
    end
    can %i[read], InternshipOffer
    can %i[create delete], Favorite
    can :apply, InternshipOffer do |internship_offer|
      student_can_apply?(student: user, internship_offer: internship_offer)
    end
    can %i[submit_internship_application update show internship_application_edit],
        InternshipApplication do |internship_application|
      internship_application.student.id == user.id
    end
    can(:cancel, InternshipApplication) do |internship_application|
      ok_canceling = %w[ submitted
                         read_by_employer
                         examined
                         validated_by_employer
                         approved
                         convention_signed]
      user.student? && ok_canceling.include?(internship_application.aasm_state)
    end

    can %i[show
           update
           choose_school
           choose_class_room
           choose_gender_and_birthday
           register_with_phone], User
    can_read_dashboard_students_internship_applications(user: user)
  end

  def admin_officer_abilities(user:)
    can %i[
      read
      create
      edit
      edit_activity_rating_rich_text
      edit_complementary_terms_rich_text
      edit_financial_conditions_rich_text
      edit_legal_terms_rich_text
      edit_main_teacher_full_name
      edit_school_representative_full_name
      edit_school_representative_phone
      edit_school_representative_email
      edit_school_representative_role
      edit_school_delegation_to_sign_delivered_at
      edit_student_refering_teacher_full_name
      edit_student_refering_teacher_email
      edit_student_refering_teacher_phone
      edit_student_address
      edit_student_class_room
      edit_student_full_name
      edit_student_phone
      edit_student_legal_representative_email
      edit_student_legal_representative_full_name
      edit_student_legal_representative_phone
      edit_student_legal_representative_2_email
      edit_student_legal_representative_2_full_name
      edit_student_legal_representative_2_phone
      edit_student_school
      see_intro
      update
    ], InternshipAgreement do |agreement|
      agreement.internship_application.student.school_id == user.school_id
    end
    can %i[edit update], InternshipAgreementPreset do |internship_agreement_preset|
      internship_agreement_preset.school_id == user.school_id
    end
    can :create, Signature  do |signature|
      signature.internship_agreement.student.school == user.school
    end
  end

  def school_manager_abilities(user:)
    can %i[list_invitations
           create_invitation
           destroy_invitation], Invitation do |invitation|
      invitation.school.id == user.school_id
    end

    can_manage_school(user: user) do
      can [:delete], User do |managed_user_from_school|
        managed_user_from_school.school_id == user.school_id
      end
    end
    can %i[
      read
      create
      edit
      sign_internship_agreements
      edit_activity_rating_rich_text
      edit_complementary_terms_rich_text
      edit_financial_conditions_rich_text
      edit_legal_terms_rich_text
      edit_main_teacher_full_name
      edit_school_representative_full_name
      edit_school_representative_phone
      edit_school_representative_email
      edit_school_representative_role
      edit_school_delegation_to_sign_delivered_at
      edit_student_refering_teacher_full_name
      edit_student_refering_teacher_email
      edit_student_refering_teacher_phone
      edit_student_address
      edit_student_class_room
      edit_student_full_name
      edit_student_phone
      edit_student_legal_representative_email
      edit_student_legal_representative_full_name
      edit_student_legal_representative_phone
      edit_student_legal_representative_2_email
      edit_student_legal_representative_2_full_name
      edit_student_legal_representative_2_phone
      edit_student_school
      see_intro
      update
    ], InternshipAgreement do |agreement|
      agreement.internship_application.student.school_id == user.school_id
    end
    can %i[edit update], InternshipAgreementPreset do |internship_agreement_preset|
      internship_agreement_preset.school_id == user.school_id
    end
    can :create, Signature do |signature|
      signature.internship_agreement.school_manager == user.id
    end
  end

  def employer_abilities(user:)
    as_employers_like(user: user)
    as_employers_signatory_abilities(user: user)
    as_account_user(user: user)
    can %i[sign_with_sms choose_function subscribe_to_webinar] , User
    can :see_minister_video, User
  end

  def as_account_user(user:)
    can :show, :account
  end

  def as_employers_like(user:)
    can_manage_teams(user: user)
    can_manage_areas(user: user)
    can %i[index], Acl::InternshipOfferDashboard
    can :supply_offers, User
    can :renew, InternshipOffer do |internship_offer|
      renewable?(internship_offer: internship_offer, user: user)
    end
    can :duplicate, InternshipOffer do |internship_offer|
      duplicable?(internship_offer: internship_offer, user: user)
    end
    can %i[create see_tutor], InternshipOffer
    can %i[read update discard publish], InternshipOffer , employer_id: user.team_members_ids
    can %i[create], InternshipOfferInfo
    can %i[create], HostingInfo
    can %i[create], PracticalInfo
    can %i[create], Organisation
    can %i[update edit renew], InternshipOfferInfo , employer_id: user.team_members_ids
    can %i[update edit renew], HostingInfo , employer_id: user.team_members_ids
    can %i[update edit renew], PracticalInfo , employer_id: user.team_members_ids
    can %i[update edit], Organisation , employer_id: user.team_members_ids
    can %i[create], Tutor
    can %i[index update], InternshipApplication
    can %i[show transfer], InternshipApplication do |internship_application|
      internship_application.internship_offer.employer_id == user.team_id
    end
  end

  def as_employers_signatory_abilities(user:)
    can :create, InternshipAgreement
    can %i[
      read
      index
      edit
      update
      edit_organisation_representative_role
      edit_tutor_email
      edit_tutor_role
      edit_activity_scope_rich_text
      edit_activity_preparation_rich_text
      edit_activity_learnings_rich_text
      edit_complementary_terms_rich_text
      edit_date_range
      edit_organisation_representative_full_name
      edit_siret
      edit_tutor_full_name
      edit_weekly_hours
      sign
      sign_internship_agreements
    ], InternshipAgreement do |agreement|
      agreement.employer.id.in?(user.team_members_ids)
    end
    can :create, Signature do |signature|
      signature.internship_agreement.internship_offer.internship_offer_area.employer_id.in?(user.team_members_ids)
    end
  end

  def can_manage_teams(user: )
    can %i[manage_teams], TeamMemberInvitation
    can %i[destroy], TeamMemberInvitation do |team_member_invitation|
      if user.team.alive?
        condition = user.team.id_in_team?(team_member_invitation.member_id)
      else
        condition = user == team_member_invitation.inviter_id
      end
      team_member_invitation.member_id != user.id && condition
    end
  end

  def can_manage_areas(user: )
    can %i[create index], InternshipOfferArea

    can %i[update], InternshipOfferArea do |area|
      if user.team.alive?
        user.team.id_in_team?(area.employer_id)
      else
        user.id == area.employer_id
      end
    end

    can %i[destroy], InternshipOfferArea do |area|
      if user.team.alive?
        condition = user.team.id_in_team?(area.employer_id)
      else
        condition = user.id == area.employer_id
      end
      user.team_areas.count > 1 && condition
    end

    can :generaly_destroy, InternshipOfferArea, user.team_areas.count > 1


    can :flip_notification, AreaNotification do |_area_notif|
      return false if user.team.not_exists?

      many_people_in_charge_of_area = !user.current_area.single_human_in_charge?
      current_area_notifications_are_off = !user.fetch_current_area_notification.notify
      many_people_in_charge_of_area || current_area_notifications_are_off
    end

    can :manage_abilities, AreaNotification do |area_notification|
      return false if user.team.not_exists?

      area_notification.internship_offer_area.employer_id.in?(user.team_members_ids)
    end
  end

  def operator_abilities(user:)
    as_account_user(user:user)
    as_employers_like(user:user)

    can :choose_operator, :sign_up
    can :change, :department
    can %i[update discard], InternshipOffers::Api, employer_id: user.team_members_ids
    can :create, InternshipOffers::Api
    can :show, :api_token
    can %i[index_and_filter], Reporting::InternshipOffer
    can %i[index], Sector
    can %i[index], Acl::Reporting do |_acl|
      true
    end
    can %i[see_reporting_internship_offers
           export_reporting_dashboard_data
           see_reporting_schools
           see_reporting_enterprises
           check_his_statistics], User
  end

  def statistician_abilities(user:)
    common_to_all_statisticians(user: user)

    can :show, :api_token

    can %i[create], Organisation

    can %i[index], Acl::Reporting, &:allowed?

    can %i[index_and_filter], Reporting::InternshipOffer
    can %i[ see_reporting_dashboard
            see_dashboard_administrations_summary
            see_dashboard_department_summary
            export_reporting_dashboard_data
            see_dashboard_associations_summary
            export_reporting_school], User
    can :view, :department
  end

  def education_statistician_abilities(user:)
    common_to_all_statisticians(user: user)
    can %i[create], Organisation
    can %i[index], Acl::Reporting, &:allowed?

    can %i[index_and_filter], Reporting::InternshipOffer
    can %i[ see_reporting_dashboard
            see_dashboard_administrations_summary
            see_dashboard_department_summary
            export_reporting_dashboard_data
            see_dashboard_associations_summary], User
    can :view, :department
  end

  def ministry_statistician_abilities(user: )
    common_to_all_statisticians(user: user)

    can %i[create], Organisation do  |organisation|
      organisation.group.in?(user.ministries) && organisation.is_public
    end

    can %i[index_and_filter], Reporting::InternshipOffer
    can :read, Group
    can %i[index], Acl::Reporting, &:ministry_statistician_allowed?
    can %i[ export_reporting_dashboard_data
            see_ministry_dashboard
            see_dashboard_associations_summary ], User
  end

  def common_to_all_statisticians(user: )
    as_employers_like(user: user)
    as_employers_signatory_abilities(user: user) if user.agreement_signatorable?
    can %i[
      choose_statistician_type
      supply_offers
      subscribe_to_webinar
      choose_to_sign_agreements
      ], User

    can %i[see_reporting_dashboard
           see_dashboard_administrations_summary], User
  end

  def common_school_management_abilities(user:)
    can %i[list_invitations
      create_invitation
      destroy_invitation], Invitation do |invitation|
        invitation.school.id == user.school_id
    end

    can %i[
      welcome_students
      subscribe_to_webinar
      sign_with_sms], User
    can :choose_role, User unless user.school_manager?
    can_create_and_manage_account(user: user) do
      can [:choose_class_room], User
    end
    can_read_dashboard_students_internship_applications(user: user)

    can :change, ClassRoom do |class_room|
      class_room.school_id == user.school_id && !user.school_manager?
    end

    can_manage_school(user: user) do
      can %i[edit update], School
      can %i[manage_school_users
             manage_school_students
             manage_school_internship_agreements], School do |school|
        school.id == user.school_id
      end
    end
    can %i[submit_internship_application validate_convention],
        InternshipApplication do |internship_application|
      internship_application.student.school_id == user.school_id
    end
    can %i[update destroy], InternshipApplication do |internship_application|
      user.school
          .students
          .where(id: internship_application.student.id)
          .count
          .positive?
    end
    can %i[see_tutor], InternshipOffer
    can %i[read], InternshipAgreement do |agreement|
      agreement.internship_application.student.school_id == user.school_id
    end
  end

  private

  def can_read_dashboard_students_internship_applications(user:)
    can [:dashboard_index], Users::Student do |student|
      student.id == user.id || student_managed_by?(student: student, user: user)
    end

    can [:dashboard_show], InternshipApplication do |internship_application|
      internship_application.student.id == user.id ||
        student_managed_by?(student: internship_application.student, user: user)
    end
  end

  def student_managed_by?(student:, user:)
    student.school_id == user.school_id &&
      user.is_a?(Users::SchoolManagement)
  end

  def shared_signed_in_user_abilities(user:)
    can :update, user
  end

  def can_create_and_manage_account(user:)
    can :show, :account
    can %i[show edit update], User
    can [:choose_school], :sign_up
    can :choose_school, User, id: user.id
    yield if block_given?
  end

  def can_manage_school(user:)
    can %i[
      show
      edit
      update
      create
      destroy
      manage_school_users
      index
    ], ClassRoom do |class_room|
      class_room.school_id == user.school_id
    end
    can :change, ClassRoom do |class_room|
      class_room.school_id == user.school_id && !user.school_manager?
    end

    can [:show_user_in_school], User do |user|
      user.school
          .users
          .map(&:id)
          .map(&:to_i)
          .include?(user.id.to_i)
    end
    yield if block_given?
  end

  def renewable?(internship_offer:, user:)
    main_condition = internship_offer.persisted? &&
                     internship_offer.employer_id == user.id
    return false unless main_condition

    school_year_start = SchoolYear::Current.new.beginning_of_period
    internship_offer.last_date <= school_year_start
  end

  def duplicable?(internship_offer:, user:)
    main_condition = internship_offer.persisted? &&
                     internship_offer.employer_id == user.id
    return false unless main_condition

    school_year_start = SchoolYear::Current.new.beginning_of_period
    internship_offer.last_date > school_year_start
  end

  def student_can_apply?(internship_offer:, student:)
    return true if student.class_room.nil? || student.school.nil? || !student.school.has_weeks_on_current_year?
    return false if student.has_already_approved_an_application?
    return false if student.school_and_offer_common_weeks(internship_offer).empty?

    offer_is_reserved_to_another_school = internship_offer.reserved_to_school? && (internship_offer.school_id != student.school_id)
    !offer_is_reserved_to_another_school
  end
end
