# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user = nil)
    if user.present?
      case user.type
      when 'Users::Student' then student_abilities(user: user)
      when 'Users::Employer' then employer_abilities(user: user)
      when 'Users::SchoolManager' then school_manager_abilities(user: user)
      when 'Users::God' then god_abilities(user: user)
      when 'Users::MainTeacher' then main_teacher_abilities(user: user)
      when 'Users::Teacher' then teacher_abilities(user: user)
      when 'Users::Other' then other_abilities(user: user)
      when 'Users::Operator' then operator_abilities(user: user)
      end
      shared_abilities(user: user)
    else
      visitor_abilities(user: user)
    end
  end

  def visitor_abilities(user:)
    can :read, InternshipOffer
  end

  def student_abilities(user:)
    can :show, :account
    can :change, :class_room
    can :read, InternshipOffer
    can :apply, InternshipOffer do |internship_offer|
      internship_offer.school_id.nil?
    end
    can :submit_internship_application, InternshipApplication do |internship_application|
      internship_application.student.id == user.id
    end
    can %i[show update], User
    can %i[choose_school choose_class_room choose_gender_and_birthday], :sign_up
    can_read_dashboard_students_internship_applications(user: user)
  end

  def school_manager_abilities(user:)
    can_create_and_manage_account(user: user)
    can_read_dashboard_students_internship_applications(user: user)

    can_read_dashboard(user: user) do
      can %i[create new update], ClassRoom
      can %i[edit update], School
      can [:manage_school_users], School do |school|
        school.id == user.school_id
      end
      can [:delete], User do |managed_user_from_school|
        managed_user_from_school.school_id == user.school_id
      end
    end
    can %i[update], InternshipApplication do |internship_application|
      user.school.students.where(id: internship_application.student.id).count > 0
    end
    can [:apply], InternshipOffer do |internship_offer|
      internship_offer.school_id == user.school_id
    end
  end

  def main_teacher_abilities(user:)
    # user account rights
    can_create_and_manage_account(user: user) do
      can [:choose_class_room], :sign_up
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

  end

  def teacher_abilities(user:)
    can_create_and_manage_account(user: user) do
      can [:choose_class_room], :sign_up
    end
    can_read_dashboard_students_internship_applications(user: user)
  end

  def other_abilities(user:)
    can_create_and_manage_account(user: user)
    can_read_dashboard_students_internship_applications(user: user)
    can_read_dashboard(user: user) do
      can [:manage_school_users], School do |school|
        school.id == user.school_id
      end
    end
  end

  def employer_abilities(user:)
    can :show, :account
    can :create, InternshipOffer
    can %i[read update discard], InternshipOffer, employer_id: user.id
    can %i[index update], InternshipApplication
  end

  def operator_abilities(user:)
    can :show, :account
    can :choose_operator, :sign_up
    can :create, InternshipOffer
    can %i[read update discard], InternshipOffer, employer_id: user.id
    can :create, Api::InternshipOffer
    can %i[update discard], Api::InternshipOffer, employer_id: user.id
    can :index, InternshipApplication
    can :show, :api_token
  end

  def god_abilities(user:)
    can :show, :account
    can :manage, School
    can :destroy, InternshipOffer
    can %i[destroy index], Feedback
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

  def shared_abilities(user:)
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
