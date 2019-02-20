class Ability
  include CanCan::Ability

  def initialize(user)
    case user.role
    when User::Roles::Visitor then visitor_abilities(user: user)
    when User::Roles::Student then student_abilities(user: user)
    when User::Roles::Employer then employer_abilities(user: user)
    when User::Roles::Reporting then reporting_abilities(user: user)
    when User::Roles::God then god_abilities(user: user)
    else fail ArgumentError, "Unknown role for user"
    end
  end

  def visitor_abilities(user:)
    can :read, InternshipOffer
  end

  def student_abilities(user:)
    can :read, InternshipOffer
  end

  def employer_abilities(user:)
    can :manage, InternshipOffer
  end

  def reporting_abilities(user:)
    can :read, InternshipOffer
  end

  def god_abilities(user:)
    can :manage, :all
  end
end
