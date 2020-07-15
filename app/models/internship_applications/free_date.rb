module InternshipApplications
  class FreeDate < InternshipApplication
    def weekly_framed?
      false
    end

    def at_most_one_application_per_student?
      true
    end
  end
end
