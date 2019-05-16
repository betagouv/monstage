module InternshipApplicationsHelper
  def timeline_step_1_ready?(internship_application)
    internship_application.aasm_state != 'drafted'
  end

  def timeline_step_2_ready?(internship_application)
    internship_application.aasm_state == 'submitted' ||
    internship_application.aasm_state == 'approved' ||
    internship_application.aasm_state == 'rejected' ||
    internship_application.aasm_state == 'convention_signed'

  end

  def timeline_step_3_ready?(internship_application)
    internship_application.aasm_state == 'convention_signed'
  end

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
end
