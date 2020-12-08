# frozen_string_literal: true

class CreateSupportTicketJob < ActiveJob::Base
  queue_as :default

  def perform(params:)
    zammad_service = Services::ZammadTicket.new(params: params)

    existing_customer = zammad_service.lookup_user
    zammad_service.create_user if existing_customer.empty?
    zammad_service.create_ticket
  end
end
