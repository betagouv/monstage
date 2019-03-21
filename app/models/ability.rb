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
      else
      end
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
    can [:choose_school, :choose_class_room, :choose_full_name, :choose_gender_and_birthday], :sign_up
  end

  def school_manager_abilities(user:)
    can :show, :account
    can [:create, :new, :update], ClassRoom
    can [:show, :edit, :update], User
    can [:edit, :update], School
    can :choose_school
  end

  def main_teacher_abilities(user:)
    can :show, :account
    can [:show, :edit, :update], User
    can [:choose_school, :choose_class_room, :choose_full_name], :sign_up
  end

  def teacher_abilities(user:)
    can :show, :account
    can [:show, :edit, :update], User
    can [:choose_school, :choose_class_room, :choose_full_name], :sign_up
  end

def other_abilities(user:)
    can :show, :account
    can [:show, :edit, :update], User
    can [:choose_school, :choose_full_name], :sign_up
  end

  def employer_abilities(user:)
    can :show, :account
    can :create, InternshipOffer
    can [:read, :update, :destroy], InternshipOffer, employer_id: user.id
    can :update, InternshipApplication
  end

  def god_abilities(user:)
    can :show, :account
    can :manage, School
    can :destroy, InternshipOffer
  end
end
