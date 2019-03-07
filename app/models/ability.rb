class Ability
  include CanCan::Ability

  def initialize(user=nil)
    if user.present?
      case user.type
      when 'Student' then student_abilities(user: user)
      when 'Employer' then employer_abilities(user: user)
      when 'SchoolManager' then school_manager_abilities(user: user)
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
    can :read, InternshipOffer
    can :apply, InternshipOffer
  end

  def school_manager_abilities(user:)
    can [:create, :new], ClassRoom
  end
  def employer_abilities(user:)
    can [:create, :read, :update, :destroy], InternshipOffer
  end
end
