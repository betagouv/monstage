module Users
  class Other < User
    include ManagedUser
    include TargetableInternshipOffersForSchool
  end
end
