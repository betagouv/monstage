# frozen_string_literal: true

class SendStatisticianValidatedEmailJob < ApplicationJob
  queue_as :default

  def perform(statistician)
    StatisticianMailer.notify_ready(statistician).deliver_later
  end
end
