module Triggered
  class SingleApplicationReminderJob < ApplicationJob
    queue_as :default
    def perform(student_id)
      student = Users::Student.find(student_id)
      return nil unless student&.kept?
        
      notify_with_channel(student) if notifiable?(student, 2)
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
        StudentMailer.single_application_reminder_email(student: student)
                     .deliver
      end
    end

    def send_sms_to_student(student)
      url = Rails.application.routes.url_helpers.internship_offers_url(
        host: ENV.fetch('HOST'),
        **student.default_search_options
      )
      shrinked_url = UrlShrinker.short_url(url: url, user_id:student.id)
      content = "Multipliez vos chances de trouver un stage ! Envoyez au moins " \
                "3 candidatures sur notre site : #{shrinked_url} . " \
                "L'équipe Mon stage de troisieme "
      SendSmsJob.new.perform(user: student, message: content)
    end
  end
end