class Ability
  include CanCan::Ability

  def initialize(user=nil)
    if user.present?
      case user.type
      when 'Users::Student' then student_abilities(user: user)
      when 'Users::Employer' then employer_abilities(user: user)
      when 'Users::SchoolManager' then school_manager_abilities(user: user)
      when 'Users::God' then god_abilities(user: user)
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
  end

  def school_manager_abilities(user:)
    can :show, :account
    can [:create, :new, :update], ClassRoom
    can [:show, :edit, :update], User
    can [:edit, :update], School
  end

  def employer_abilities(user:)
    can :show, :account
    can :create, InternshipOffer
    can [:read, :update, :destroy], InternshipOffer, employer_id: user.id
  end

  def god_abilities(user:)
    can :show, :account
    can :manage, School
  end
end
