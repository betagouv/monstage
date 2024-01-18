# frozen_string_literal: true

module Triggered
  class StudentSmsInternshipApplicationReminderJob < ApplicationJob
    queue_as :default

    def perform(internship_application_id)
      internship_application = InternshipApplication.find(internship_application_id)
      student = internship_application.student
      phone = student.phone || (internship_application.student_phone.present? && internship_application.student_phone.gsub(/^0/, '+33'))
      if phone.present? && phone.match?(/\A\+33[6-7]\d{8}\z/)

        sgid = student.to_sgid(expires_in: InternshipApplication::MAGIC_LINK_EXPIRATION_DELAY).to_s
        url = Rails.application.routes.url_helpers.dashboard_students_internship_application_url(
          sgid: sgid,
          student_id: student.id,
          id: internship_application.id,
          host: ENV['HOST']
        )

        url = internship_application.short_target_url(internship_application)

        notify(student: student, application_id: internship_application.id, url: url, phone: phone)
      else
        Rails.logger.error("StudentSmsInternshipApplicationReminderJob: phone is not on the right format for student #{student.id}")
      end
    end

    private

    def notify(student:, application_id:, url:, phone:)
      message = "Vous êtes accepté à un stage. Confirmez votre présence :" \
                "#{url}. L'équipe mon stage de troisième."
      SendSmsJob.new.perform_later(user: student, message: message, phone: phone)
      info = "StudentSmsInternshipApplicationReminderJob: SMS " \
             "sent to #{student.id} with response #{response}"
      Rails.logger.info(info)
    end
  end
end
