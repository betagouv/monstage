module InternshipApplicationsHelper
  def is_resume_empty?(internship_application)
    [
      has_resume_educational_background?(internship_application),
      has_resume_other?(internship_application),
      has_resume_volunteer_work?(internship_application),
      has_resume_languages?(internship_application),
    ].all?(&:nil?)
  end

  def has_resume_educational_background?(internship_application)
    internship_application.student
                          .resume_educational_background
                          .present?
  end

  def has_resume_other?(internship_application)
    internship_application.student
                          .resume_other
                          .present?
  end

  def has_resume_volunteer_work?(internship_application)
    internship_application.student
                          .resume_volunteer_work
                          .present?
  end

  def has_resume_languages?(internship_application)
    internship_application.student
                          .resume_languages
                          .present?
  end
end
