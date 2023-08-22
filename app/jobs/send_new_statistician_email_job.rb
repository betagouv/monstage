# frozen_string_literal: true

class SendNewStatisticianEmailJob < ApplicationJob
  queue_as :default

  def perform(statistician)
    GodMailer.new_statistician_email(statistician).deliver_later
  end
end
