module Users
  class God < User
    scope :targeted_internship_offers, -> (user:) { InternshipOffer.all }
  end
end
