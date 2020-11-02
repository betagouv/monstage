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
      when 'Users::Statistician' then statistician_abilities
      when 'Users::SchoolManagement' then school_management_abilities(user: user)
      end
      shared_signed_in_user_abilities(user: user)
    else
      visitor_abilities
    end
  end

  def visitor_abilities
    can :read, InternshipOffer
  end

  def student_abilities(user:)
    can :show, :account
    can :change, :class_room
    can %i[read], InternshipOffer
    can :apply, InternshipOffer do |internship_offer|
      !(internship_offer.reserved_to_school? && (internship_offer.school_id != user.school_id)) &&
        !internship_offer.from_api? &&
        user.try(:class_room).try(:applicable?, internship_offer)
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

  def school_management_abilities(user:)
    can :choose_role, User
    can_create_and_manage_account(user: user) do
      can [:choose_class_room], User
    end
    can_read_dashboard_students_internship_applications(user: user)

    can :change, :class_room unless user.school_manager?
    can [:create, :update], InternshipAgreement do |agreement|
      agreement.internship_application.student.school_id == user.school_id
    end
    can :new, InternshipAgreement, internship_application_id: user.id

    can_manage_school(user: user) do
      can %i[edit update], School
      can %i[edit update], School
      can %i[manage_school_users
             manage_school_students
             manage_school_internship_agreements], School do |school|
        school.id == user.school_id
      end
      can [:delete], User do |managed_user_from_school|
        managed_user_from_school.school_id == user.school_id && user.school_manager?
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

  def employer_abilities(user:)
    can :show, :account
    # internship_offer mgmt
    can :manage, InternshipAgreement
    can %i[create see_tutor], InternshipOffer
    can %i[read update discard], InternshipOffer, employer_id: user.id
    # internship_offer stepper
    can %i[create], InternshipOfferInfo
    can %i[update edit], InternshipOfferInfo, employer_id: user.id
    can %i[create], Organisation
    can %i[update edit], Organisation, employer_id: user.id
    can %i[create], Tutor

    can %i[index update], InternshipApplication
    can %i[index], Acl::InternshipOfferDashboard, &:allowed?
  end

  def operator_abilities(user:)
    can :show, :account
    can :choose_operator, :sign_up
    can :change, :department_name
    can %i[create see_tutor], InternshipOffer
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
    can %i[index], Acl::Reporting do |_acl|
      true
    end
  end

  def statistician_abilities
    can :view, :department_name
    can %i[read], InternshipOffer

    can %i[index], Acl::Reporting, &:allowed?

    can %i[index_and_filter], Reporting::InternshipOffer
  end

  def god_abilities
    can :show, :account
    can :manage, School
    can :manage, Sector
    can %i[destroy see_tutor], InternshipOffer
    can %i[read update destroy export], User
    can :switch_user, User
    can %i[read update export], InternshipOffer
    can :manage, EmailWhitelist
    can :manage, InternshipOfferKeyword
    can %i[create read update], Group
    can :access, :rails_admin   # grant access to rails_admin
    can %i[read update delete discard export], InternshipOffers::Api
    can :read, :dashboard       # grant access to the dashboard
    can :read, :kpi # grant access to the dashboard
    can %i[index], Acl::Reporting do |_acl|
      true
    end
    can %i[index_and_filter], Reporting::InternshipOffer
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
end
