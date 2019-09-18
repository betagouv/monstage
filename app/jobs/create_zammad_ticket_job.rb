class CreateZammadTicketJob < ApplicationJob
  queue_as :default

  def perform(feedback)
    client = ZammadAPI::Client.new(
      url:        Rails.application.credentials.zammad[:url],
      http_token: Rails.application.credentials.zammad[:http_token],
    )

    begin
      client.user.create(email: feedback.email)
    rescue RuntimeError
      # Dirty, but it is the error we get when the user already exists in zammad
      # In the future we should probaly have some kind of temporary user to avoid this
    end

    client.perform_on_behalf_of(feedback.email) do
      client.ticket.create(
        title: "Demande n°#{feedback.id}",
        state: 'new',
        group: 'Users',
        article: {
          body: feedback.comment
        }
      )
    end

  end
end
