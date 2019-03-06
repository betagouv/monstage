class Employer < User
  def targeted_internship_offers
    InternshipOffer.all
  end
end
