class Ability
  include CanCan::Ability

  def initialize(user=nil)
    if user.present?
      case user.type
      when 'Student' then student_abilities(user: user)
      when 'Employer' then employer_abilities(user: user)
      when 'SchoolManager' then school_manager_abilities(user: user)
      when 'God' then god_abilities(user: user)
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
    can :show, School
  end

  def school_manager_abilities(user:)
    can :show, :account
    can [:create, :new, :update], ClassRoom
    can [:show, :edit, :update], User
    can [:show, :edit, :update], School
  end

  def employer_abilities(user:)
    can :show, :account
    can :create, InternshipOffer
    can [:read, :update, :destroy], InternshipOffer, employer_id: user.id
    can :edit, User
  end

  def god_abilities(user:)
    can :show, :account
    can :manage, School
    can [:create, :read, :update, :destroy], InternshipOffer
  end
end
