# frozen_string_literal: true

class FeedbacksController < ApplicationController
  before_action :authenticate_user!, only: %i[index destroy]
  before_action :set_feedback, only: [:destroy]

  # GET /feedbacks
  def index
    authorize! :index, Feedback
    @feedbacks = Feedback.all
  end

  # POST /feedbacks
  def create
    @feedback = Feedback.new(feedback_params)

    if @feedback.save
      redirect_back fallback_location: root_path,
                    flash: { success: "Votre message a bien été envoyé. Merci d'avoir donné votre avis." }
    else
      redirect_back fallback_location: root_path,
                    flash: { success: 'Woops, une erreur est survenue, veuillez ré-essayer' }
    end
  end

  # DELETE /feedbacks/1
  def destroy
    authorize! :destroy, Feedback
    @feedback.destroy
    redirect_to feedbacks_url, notice: 'Feedback was successfully destroyed.'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_feedback
    @feedback = Feedback.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def feedback_params
    params.require(:feedback).permit(:email, :comment)
  end
end
