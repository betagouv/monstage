module InternshipOffers
  class FreeDate < InternshipOffer
    has_many :internship_applications
  end
end
