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
      when 'Users::Statistician' then statistician_abilities(user: user)
      when 'Users::MinistryStatistician' then ministry_statistician_abilities
      when 'Users::SchoolManagement' then
        common_school_management_abilities(user: user)
        school_manager_abilities(user: user) if user.school_manager?
        main_teacher_abilities(user: user)   if user.main_teacher?
      end

      shared_signed_in_user_abilities(user: user)
    else
      visitor_abilities
    end
  end

  def visitor_abilities
    can %i[read apply], InternshipOffer
  end

  def student_abilities(user:)
    can :show, :account
    can :change, :class_room
    can %i[read], InternshipOffer
    can :apply, InternshipOffer do |internship_offer|
      student_can_apply?(student: user, internship_offer: internship_offer)
    end
    can %i[submit_internship_application update], InternshipApplication do |internship_application|
      internship_application.student.id == user.id
    end

    can %i[show
           update
           choose_school
           choose_class_room
           choose_gender_and_birthday
           choose_handicap
           register_with_phone], User
    can_read_dashboard_students_internship_applications(user: user)
  end

  def common_school_management_abilities(user:)
    can :choose_role, User
    can_create_and_manage_account(user: user) do
      can [:choose_class_room], User
    end
    can_read_dashboard_students_internship_applications(user: user)

    can :change, :class_room unless user.school_manager?

    can_manage_school(user: user) do
      can %i[edit update], School
      can %i[manage_school_users
             manage_school_students
             manage_school_internship_agreements], School do |school|
        school.id == user.school_id
      end
    end
    can %i[submit_internship_application validate_convention], InternshipApplication do |internship_application|
      internship_application.student.school_id == user.school_id
    end
    can %i[update destroy], InternshipApplication do |internship_application|
      user.school.students.where(id: internship_application.student.id).count.positive?
    end
    can %i[see_tutor], InternshipOffer
  end

  def school_manager_abilities(user:)
    can :create_remote_internship_request, SupportTicket
    can_manage_school(user: user) do
      can [:delete], User do |managed_user_from_school|
        managed_user_from_school.school_id == user.school_id
      end
    end
    can %i[
      create
      update
      see_intro
      edit_student_full_name
      edit_school_representative_full_name
      edit_student_class_room
      edit_student_school
      edit_main_teacher_full_name
      edit_terms_rich_text
      edit_activity_rating_rich_text
      edit_financial_conditions_rich_text
    ], InternshipAgreement do |agreement|
      agreement.internship_application.student.school_id == user.school_id
    end
  end

  def main_teacher_abilities(user:)
    can %i[
      create
      update
      see_intro
      edit_student_class_room
      edit_main_teacher_full_name
      edit_activity_rating_rich_text
      edit_activity_preparation_rich_text
        ], InternshipAgreement do |agreement|
      is_student_in_school = agreement.internship_application.student.school_id == user.school_id
      is_student_in_class_room = agreement.internship_application.student.class_room_id == user.class_room_id

      is_student_in_school && is_student_in_class_room
    end
  end

  def employer_abilities(user:)
    can :show, :account

    can :create_remote_internship_request, SupportTicket

    can %i[create see_tutor], InternshipOffer
    can %i[read update discard], InternshipOffer, employer_id: user.id
    can :renew, InternshipOffer do |internship_offer|
      renewable?(internship_offer: internship_offer, user: user)
    end
    # internship_offer stepper
    can %i[create], InternshipOfferInfo
    can %i[update edit renew], InternshipOfferInfo, employer_id: user.id
    can %i[create], Organisation
    can %i[update edit], Organisation, employer_id: user.id
    can %i[create], Tutor

    can %i[index update], InternshipApplication
    can %i[index], Acl::InternshipOfferDashboard, &:allowed?

    can %i[
      create
      update
      edit_organisation_representative_full_name
      edit_tutor_full_name
      edit_date_range
      edit_weekly_hours
      edit_activity_scope_rich_text
      edit_activity_preparation_rich_text
      edit_activity_learnings_rich_text
    ], InternshipAgreement do |agreement|
      agreement.internship_application.internship_offer.employer == user
    end
  end

  def operator_abilities(user:)
    can :show, :account
    can :choose_operator, :sign_up
    can :change, :department
    can %i[create see_tutor], InternshipOffer
    can :renew, InternshipOffer do |internship_offer|
      renewable?(internship_offer: internship_offer, user: user)
    end
    can %i[read update discard], InternshipOffer, employer_id: user.id
    can :create, InternshipOffers::Api
    can %i[update discard], InternshipOffers::Api, employer_id: user.id
    # internship_offer stepper
    can %i[create], InternshipOfferInfo
    can %i[update edit], InternshipOfferInfo, employer_id: user.id
    can %i[create], Organisation
    can %i[update edit], Organisation, employer_id: user.id
    can %i[create], Tutor
    can %i[index update], InternshipApplication
    can :show, :api_token
    can %i[index], Acl::InternshipOfferDashboard, &:allowed?
    can %i[index_and_filter], Reporting::InternshipOffer
    can %i[index import_data], Acl::Reporting do |_acl|
      true
    end
     can %i[see_reporting_internship_offers
            export_reporting_dashboard_data
            see_reporting_schools
            see_reporting_enterprises ], User
  end

  def god_abilities
    can :show, :account
    can :manage, School
    can :manage, Sector
    can %i[destroy see_tutor], InternshipOffer
    can %i[read update export], InternshipOffer
    can :manage, EmailWhitelists::Statistician
    can :manage, EmailWhitelists::Ministry
    can :manage, InternshipOfferKeyword
    can %i[create read update], Group
    can :access, :rails_admin   # grant access to rails_admin
    can %i[read update delete discard export], InternshipOffers::Api
    can :read, :dashboard       # grant access to the dashboard
    can :read, :kpi # grant access to the dashboard
    can %i[index department_filter], Acl::Reporting do |_acl|
      true
    end
    can %i[index_and_filter], Reporting::InternshipOffer
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
            see_dashboard_associations_summary
            reset_cache ], User
    can :manage, Operator
  end

  def statistician_abilities(user:)
    can :view, :department
    can %i[read create see_tutor], InternshipOffer
    can %i[read update discard], InternshipOffer, employer_id: user.id
    can :renew, InternshipOffer do |internship_offer|
      renewable?(internship_offer: internship_offer, user: user)
    end

    can %i[create], InternshipOfferInfo
    can %i[update edit], InternshipOfferInfo, employer_id: user.id

    can %i[create], Organisation
    can %i[update edit], Organisation, employer_id: user.id
    can %i[create], Tutor

    can %i[index], Acl::InternshipOfferDashboard

    can :show, :api_token

    can %i[index], Acl::InternshipOfferDashboard, &:allowed?
    can %i[index], Acl::Reporting, &:allowed?

    can %i[index_and_filter], Reporting::InternshipOffer
    can %i[ see_reporting_dashboard
            see_reporting_internship_offers
            see_reporting_schools
            see_reporting_enterprises
            see_dashboard_enterprises_summary
            see_dashboard_administrations_summary
            see_dashboard_associations_summary
            ], User
  end

  def ministry_statistician_abilities
    can :view, :department
    can %i[read], InternshipOffer
    can %i[index_and_filter], Reporting::InternshipOffer
    can :read, Group
    can %i[read], InternshipOffer
    can %i[index], Acl::Reporting, &:ministry_statistician_allowed?
    can %i[ see_reporting_dashboard
            see_dashboard_administrations_summary
            export_reporting_dashboard_data
            ], User
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
    can :manage, ClassRoom
    can [:show_user_in_school], User do |user|
      user.school
          .users
          .map(&:id)
          .map(&:to_i)
          .include?(user.id.to_i)
    end
    yield if block_given?
  end

  def renewable?(internship_offer:, user: )
    internship_offer.persisted? &&
      internship_offer.created_at.to_date <= SchoolYear::Current.new.beginning_of_period &&
      internship_offer.employer_id == user.id
  end

  def student_can_apply?(internship_offer:, student:)
    offer_is_reserved_to_another_school = internship_offer.reserved_to_school? && (internship_offer.school_id != student.school_id)

    return false if offer_is_reserved_to_another_school
    return true if internship_offer.from_api?
    return true if student.try(:class_room).nil?
    return true if student.try(:class_room).try(:applicable?, internship_offer)

    false
  end
end
