class Ability
  include CanCan::Ability

  def initialize(user)
    case user.role
    when MockUser::Roles::Visitor then visitor_abilities(user: user)
    when MockUser::Roles::Student then student_abilities(user: user)
    when MockUser::Roles::Employer then employer_abilities(user: user)
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
end
