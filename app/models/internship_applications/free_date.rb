module InternshipApplications
  class FreeDate < InternshipApplication
    def approvable?
      true
    end

    def at_most_one_application_per_student?
      true
    end
  end
end
