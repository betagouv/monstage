class StudentMailerPreview < ActionMailer::Preview
  def internship_application_requested_confirmation_email
    internship_application = InternshipApplication.validated_by_employer.first
    StudentMailer.internship_application_requested_confirmation_email(
      internship_application: internship_application
    )
  end

  def internship_application_examined_email
    internship_application = InternshipApplication.examined.first
    internship_application.examined_message =  '<strong>Bonjour !</strong><br/>Nous sommes désireux de vous accueillir, et nous cherchons activement le tuteur qui pourra vous encadrer durant cette semaine'
    StudentMailer.internship_application_examined_email(
      internship_application: internship_application
    )
  end

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
    internship_application.canceled_by_employer_message = '<strong>Nous ne comprenons pas ce qui s\'est passé ! </strong><br/>L`administration de notre société a décliné votre proposition de stage sans fournir de raison. Une enquête interne est en cours.'
    StudentMailer.internship_application_canceled_by_employer_email(
      internship_application: internship_application
    )
  end

  def internship_application_validated_by_employer_email
    internship_application = InternshipApplication.validated_by_employer.first
    StudentMailer.internship_application_validated_by_employer_email(
      internship_application: internship_application
    )
  end

  def internship_application_validated_by_employer_reminder_email
    internship_applications = InternshipApplication.validated_by_employer.to_a.compact
    StudentMailer.internship_application_validated_by_employer_reminder_email(
      applications_to_notify: internship_applications
    )
  end

  def single_application_reminder_email
    StudentMailer.single_application_reminder_email(
      student: Users::Student.first
    )
  end

  def single_application_second_reminder_email
    StudentMailer.single_application_second_reminder_email(
      student: Users::Student.first
    )
  end

  def welcome_email
    StudentMailer.welcome_email(
      student: Users::Student.first,
      shrinked_url: 'https://www.monstagedetroisieme.fr'
    )
  end
end
