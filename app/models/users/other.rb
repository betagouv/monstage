module Users
  class Other < User
    include ManagedUser
    include TargetableInternshipOffersInSchool
  end
end
