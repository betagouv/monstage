module InternshipApplications
  class FreeDate < InternshipApplication
    validates :student, uniqueness: { scope: :internship_offer_id }

    def approvable?
      true
    end

    def at_most_one_application_per_student?
      true
    end
  end
end
