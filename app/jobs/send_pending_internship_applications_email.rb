# frozen_string_literal: true

class SendPendingInternshipApplicationsEmail < ApplicationJob
  queue_as :default

  def perform
    GodMailer.weekly_pending_applications_email.deliver_later
  end
end
