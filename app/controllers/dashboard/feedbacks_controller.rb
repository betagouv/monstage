# frozen_string_literal: true

module Dashboard
  class FeedbacksController < ApplicationController

    # POST /feedbacks
    def create
      @feedback = Feedback.new(feedback_params)

      if @feedback.save
        CreateZammadTicketJob.perform_later @feedback

        redirect_back fallback_location: root_path,
                      flash: { success: "Votre message a bien été envoyé. Merci d'avoir donné votre avis." }
      else
        redirect_back fallback_location: root_path,
                      flash: { success: 'Woops, une erreur est survenue, veuillez ré-essayer' }
      end
    end

    private

    # Only allow a trusted parameter "white list" through.
    def feedback_params
      params.require(:feedback).permit(:email, :comment)
    end
  end
end
