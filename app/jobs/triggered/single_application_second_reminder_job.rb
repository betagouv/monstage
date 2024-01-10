module Triggered
  class SingleApplicationSecondReminderJob < ApplicationJob
    queue_as :default
    def perform(student_id)
      student = Users::Student.find(student_id)
      return nil unless student&.kept?
      
      notify_with_channel(student) if notifiable?(student, 5)
    end

    private

    def notifiable?(student, delay)
      student.internship_applications.count == 1 &&
        student.has_offers_to_apply_to? &&
        student.has_applied?(delay.days.ago)
    end

    def notify_with_channel(student)
      if student.phone.present?
        send_sms_to_student(student)
      else
        StudentMailer.single_application_second_reminder_email(student: student)
                     .deliver
      end
    end

    def send_sms_to_student(student)
      content =  "Pas de réponse à votre candidature ? Les employeurs peuvent être lents" \
                 " à répondre. Continuez à postuler pour maximiser vos chances de trouver" \
                 " le stage idéal sur Monstagedetroisieme.fr."
      SendSmsJob.new.perform_later(user: student, message: content)
    end
  end
end