# frozen_string_literal: true

module Dashboard
  class FeedbacksController < ApplicationController

    # POST /feedbacks
    def create
      @feedback = Feedback.create(feedback_params)

      client = ZammadAPI::Client.new(
        url:        Rails.application.credentials.zammad[:url],
        http_token: Rails.application.credentials.zammad[:http_token],
      )

      begin
        client.user.create(email: @feedback.email)
      rescue RuntimeError
        # Dirty, but it is the error we get when the user already exists in zammad
        # In the future we should probaly have some kind of temporary user to avoid this
      end

      client.perform_on_behalf_of(@feedback.email) do
        client.ticket.create(
          title: "Demande n°#{@feedback.id}",
          state: 'new',
          group: 'Users',
          article: {
            body: @feedback.comment
          }
        )
      end


      redirect_back fallback_location: root_path,
                    flash: { success: "Votre message a bien été envoyé. Merci d'avoir donné votre avis." }
      # else
      #   redirect_back fallback_location: root_path,
      #                 flash: { success: 'Woops, une erreur est survenue, veuillez ré-essayer' }
      # end
    end

    private

    # Only allow a trusted parameter "white list" through.
    def feedback_params
      params.require(:feedback).permit(:email, :comment)
    end
  end
end
