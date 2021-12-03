# frozen_string_literal: true

class SendWeeklyKpiEmail < ApplicationJob
  queue_as :default

  def perform
    GodMailer.weekly_kpis_email.deliver_later
  end
end
