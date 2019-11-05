# frozen_string_literal: true

# list abilities for users
class Ability
  include CanCan::Ability

  def initialize(user = nil)
    if user.present?
      case user.type
      when 'Users::Student' then student_abilities(user: user)
      when 'Users::Employer' then employer_abilities(user: user)
      when 'Users::SchoolManager' then school_manager_abilities(user: user)
      when 'Users::God' then god_abilities
      when 'Users::MainTeacher' then main_teacher_abilities(user: user)
      when 'Users::Teacher' then teacher_abilities(user: user)
      when 'Users::Other' then other_abilities(user: user)
      when 'Users::Operator' then operator_abilities(user: user)
      when 'Users::Statistician' then statistician_abilities
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
      !internship_offer.school_id && !internship_offer.permalink
    end
    can :submit_internship_application, InternshipApplication do |internship_application|
      internship_application.student.id == user.id
    end
    can %i[show
           update
           choose_school
           choose_class_room
           choose_gender_and_birthday
           choose_handicap], User
    can_read_dashboard_students_internship_applications(user: user)
  end

  def school_manager_abilities(user:)
    can_create_and_manage_account(user: user)
    can_read_dashboard_students_internship_applications(user: user)

    can_read_dashboard(user: user) do
      can %i[create new update destroy], ClassRoom
      can %i[edit update], School
      can [:manage_school_users], School do |school|
        school.id == user.school_id
      end
      can [:delete], User do |managed_user_from_school|
        managed_user_from_school.school_id == user.school_id
      end
    end
    can %i[update destroy], InternshipApplication do |internship_application|
      user.school.students.where(id: internship_application.student.id).count > 0
    end
    can [:apply_in_bulk], InternshipOffer do |internship_offer|
      internship_offer.school_id == user.school_id
    end
    can %i[see_tutor], InternshipOffer

  end

  def main_teacher_abilities(user:)
    # user account rights
    can_create_and_manage_account(user: user) do
      can [:choose_class_room], User
    end
    can_read_dashboard_students_internship_applications(user: user)

    # dashboard rights
    can_read_dashboard(user: user) do
      can [:manage_students], ClassRoom do |class_room|
        class_room.id == user.class_room_id
      end
    end
    can :submit_internship_application, InternshipApplication do |internship_application|
      internship_application.student.school_id == user.school_id
    end
    can %i[see_tutor], InternshipOffer
  end

  def teacher_abilities(user:)
    can_create_and_manage_account(user: user) do
      can [:choose_class_room], User
    end
    can_read_dashboard_students_internship_applications(user: user)
    can_read_dashboard(user: user)

    can %i[see_tutor], InternshipOffer
  end

  def other_abilities(user:)
    can_create_and_manage_account(user: user)
    can_read_dashboard_students_internship_applications(user: user)
    can_read_dashboard(user: user) do
      can [:manage_school_users], School do |school|
        school.id == user.school_id
      end
    end
    can %i[see_tutor], InternshipOffer
  end

  def employer_abilities(user:)
    can :show, :account
    can %i[create see_tutor], InternshipOffer
    can %i[read update discard], InternshipOffer, employer_id: user.id
    can %i[index update], InternshipApplication
  end

  def operator_abilities(user:)
    can :show, :account
    can :choose_operator, :sign_up
    can %i[create see_tutor], InternshipOffer
    can %i[read update discard], InternshipOffer, employer_id: user.id
    can :create, Api::InternshipOffer
    can %i[update discard], Api::InternshipOffer, employer_id: user.id
    can %i[index update], InternshipApplication
    can :show, :api_token
  end

  def statistician_abilities
    can %i[read], InternshipOffer
    can %i[index], Reporting::Acl do |acl|
      acl.allowed?
    end
  end

  def god_abilities
    can :show, :account
    can :manage, School
    can %i[destroy see_tutor], InternshipOffer
    can %i[read destroy export], User
    can %i[read update export], InternshipOffer
    can :manage, EmailWhitelist
    can :access, :rails_admin   # grant access to rails_admin
    can :read, :dashboard       # grant access to the dashboard
    can :read, :kpi       # grant access to the dashboard
    can %i[index], Reporting::Acl do |_acl|
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
    student.school_id == user.school_id && (
      user.is_a?(Users::Teacher) ||
      user.is_a?(Users::MainTeacher) ||
      user.is_a?(Users::SchoolManager) ||
      user.is_a?(Users::Other)
    )
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

  def can_read_dashboard(user:)
    can %i[index show], ClassRoom
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
