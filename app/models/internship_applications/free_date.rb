module InternshipApplications
  class FreeDate < InternshipApplication
    validates :student, uniqueness: { scope: :internship_offer_id }

    def approvable?
      true
    end

    def at_most_one_application_per_student?
      true
    end

    def remaining_places_count
      max_places      = internship_offer.max_candidates
      reserved_places = internship_offer.internship_applications
                                        .where(aasm_state: :approved)
                                        .count
      max_places - reserved_places
    end
  end
end
