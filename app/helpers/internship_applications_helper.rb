# frozen_string_literal: true

module InternshipApplicationsHelper
  def is_resume_empty?(internship_application)
    !has_resume_educational_background?(internship_application) &&
      !has_resume_other?(internship_application) &&
      !has_resume_languages?(internship_application)
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

  def has_resume_languages?(internship_application)
    internship_application.student
                          .resume_languages
                          .present?
  end

  def sign_application_modal_id(internship_application)
    "sign-internship-application-#{internship_application.id}-#{internship_application.user_id}"
  end
  def show_application_modal_id(internship_application)
    "show-internship-application-#{internship_application.id}-#{internship_application.user_id}"
  end
end
