# frozen_string_literal: true

class CreateSupportTicketJob < ActiveJob::Base
  queue_as :default

  def perform(params:)
    zammad_service = build_zammad_ticket_service(params: params)

    existing_customer = zammad_service.lookup_user
    zammad_service.create_user if existing_customer.empty?
    zammad_service.create_ticket
  end
end
