# frozen_string_literal: true

class InternshipApplicationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_internship_offer

  def index
    set_intership_applications
    authorize! :read, @internship_offer
    authorize! :index, InternshipApplication
  end

  # alias for draft
  def show
    @internship_application = @internship_offer.internship_applications.find(params[:id])
    authorize! :submit_internship_application, @internship_application
  end

  # alias for submit/update
  def update
    @internship_application = @internship_offer.internship_applications.find(params[:id])
    authorize! :submit_internship_application, @internship_application

    if params[:transition] == 'submit!'
      @internship_application.submit!
      @internship_application.save!
      redirect_to dashboard_students_internship_applications_path(@internship_application.student, @internship_application),
                  flash: { success: 'Votre candidature a bien été envoyée' }
    else
      @internship_application.update(update_internship_application_params)
      redirect_to internship_offer_internship_application_path(@internship_offer, @internship_application)
    end
  rescue AASM::InvalidTransition
    redirect_to dashboard_students_internship_applications_path(current_user, @internship_application),
                flash: { warning: 'Votre candidature avait déjà été soumise' }
  rescue ActiveRecord::RecordInvalid
    flash[:error] = 'Erreur dans la saisie de votre candidature'
    render 'internship_application/show'
  end

  # students can candidate for one internship_offer
  def create
    set_internship_offer
    authorize! :apply, @internship_offer
    @internship_application = InternshipApplication.create!(create_internship_application_params)
    redirect_to internship_offer_internship_application_path(@internship_offer,
                                                             @internship_application)
  rescue ActiveRecord::RecordInvalid => e
    @internship_application = e.record
    render 'internship_offers/show', status: :bad_request
  end

  private

  def set_intership_applications
    @internship_applications = @internship_offer.internship_applications
                                                .order(updated_at: :desc)
                                                .page(params[:page])
  end

  def set_internship_offer
    @internship_offer = InternshipOffer.find(params[:internship_offer_id])
  end

  def update_internship_application_params
    params.require(:internship_application)
          .permit(
            :motivation,
            student_attributes: %i[
              phone
              resume_educational_background
              resume_other
              resume_languages
            ]
          )
  end

  def create_internship_application_params
    params.require(:internship_application)
          .permit(
            :motivation,
            :internship_offer_week_id,
            :user_id,
            student_attributes: %i[
              phone
              resume_educational_background
              resume_other
              resume_languages
            ]
          )
  end
end
