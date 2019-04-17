class Ability
  include CanCan::Ability

  def initialize(user=nil)
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
      else
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
    can :read, InternshipOffer
    can :apply, InternshipOffer
    can [:show, :update], User
    can [:choose_school, :choose_class_room, :choose_gender_and_birthday], :sign_up
  end

  def school_manager_abilities(user:)
    can_create_and_manage_account(user: user)

    can_read_dashboard(user: user) do
      can [:create, :new, :update], ClassRoom
      can [:edit, :update], School
      can [:manage_school_users], School do |school|
        school.id == user.school_id
      end
      can [:delete], User do |managed_user_from_school|
        managed_user_from_school.school_id == user.school_id
      end
    end
  end

  def main_teacher_abilities(user:)
    # user account rights
    can_create_and_manage_account(user: user) do
      can [:choose_class_room], :sign_up
    end

    # dashboard rights
    can_read_dashboard(user: user) do
      can [:manage_students], ClassRoom do |class_room|
        class_room.id == user.class_room_id
      end
    end
  end

  def teacher_abilities(user:)
    can_create_and_manage_account(user: user) do
      can [:choose_class_room], :sign_up
    end
  end

  def other_abilities(user:)
    can_create_and_manage_account(user: user)

    can_read_dashboard(user: user) do
      can [:manage_school_users], School do |school|
        school.id == user.school_id
      end
    end
  end

  def employer_abilities(user:)
    can :show, :account
    can :create, InternshipOffer
    can [:read, :update, :destroy], InternshipOffer, employer_id: user.id
    can [:index, :update], InternshipApplication
  end

  def operator_abilities(user:)
    can :show, :account
    can :choose_operator, :sign_up
    can :create, InternshipOffer
    can [:read, :update, :destroy], InternshipOffer, employer_id: user.id
    can :index, InternshipApplication
  end

  def god_abilities(user:)
    can :show, :account
    can :manage, School
    can :destroy, InternshipOffer
    can [:destroy, :index], Feedback
  end


  private
  def shared_abilities(user:)
    can :update, user
  end

  def can_create_and_manage_account(user:)
    can :show, :account
    can [:show, :edit, :update], User
    can [:choose_school], :sign_up
    yield if block_given?
  end

  def can_read_dashboard(user:)
    can [:index, :show], ClassRoom
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
