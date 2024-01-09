module Triggered
  class SingleApplicationSecondReminderJob < ApplicationJob
    queue_as :default
    def perform(student_id)
      student = Users::Student.find(student_id)
      return nil unless student&.kept?
      
      if student.phone.present?
        send_sms_to_student(student)
      else
        StudentMailer.single_application_second_reminder_email(student: student)
                     .deliver
      end
    end

    private

    def send_sms_to_student(student)
      content =  "Pas de réponse à votre candidature ? Les employeurs peuvent être lents" \
                 " à répondre. Continuez à postuler pour maximiser vos chances de trouver" \
                 " le stage idéal sur Monstagedetroisieme.fr."
      SendSmsJob.new.perform_later(user: student, message: content)
    end
  end
end