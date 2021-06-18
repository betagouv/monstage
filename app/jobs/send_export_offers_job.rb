# frozen_string_literal: true

class SendExportOffersJob < ApplicationJob
  queue_as :default

  def perform(user, params)
    UserMailer.export_offers(user.email, params).deliver_now
  end
end