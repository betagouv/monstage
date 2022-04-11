class StudentMailerPreview < ActionMailer::Preview
  def internship_application_approved_email
    internship_application = InternshipApplication.approved.first
    internship_application.approved_message =  '<strong>Bravo ! Vraiment ! </strong><br/>Vous étiez nombreux à le vouloir, ce stage'
    StudentMailer.internship_application_approved_email(
      internship_application: internship_application
    )
  end

  def internship_application_rejected_email
    internship_application = InternshipApplication.canceled_by_student.first
    internship_application.rejected_message = '<strong>Tellement désolés ! Vraiment ! </strong><br/>Vous trouverez ailleurs tel que vous êtes, ne changez rien'
    StudentMailer.internship_application_rejected_email(
      internship_application: internship_application
    )
  end

  def internship_application_canceled_by_employer_email
    internship_application = InternshipApplication.canceled_by_employer.first
    internship_application.canceled_by_employer_message = '<strong>Nous ne comprenons pas ce qui s\'est passé ! </strong><br/>L`administration de notre société a décliné votre proposition de stage au prétexte d\'un casier judiciaire "particulièrement" lourd, mais une enquête interne vous tiendra informé des véritables raisons de ce rejet de candidature'
    StudentMailer.internship_application_canceled_by_employer_email(
      internship_application: internship_application
    )
  end
end
