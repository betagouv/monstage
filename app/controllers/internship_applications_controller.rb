# frozen_string_literal: true

class InternshipApplicationsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_internship_offer

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
  rescue AASM::InvalidTransition => e
    redirect_to dashboard_students_internship_applications_path(current_user, @internship_application),
                flash: { warning: 'Votre candidature avait déjà été soumise' }
  rescue ActiveRecord::RecordInvalid => e
    flash[:error] = 'Erreur dans la saisie de votre candidature'
    render 'internship_application/show'
  end

  # school manager can candidate for many students for reserved internship_offers
  def bulk_create
    success_applications = []
    error_applications = []
    internship_application_builder.create_many(params: bulk_create_internship_application_params) do |on|
      on.bulk_unit_success do |success_internship_application|
        success_applications.push(success_internship_application)
      end
      on.bulk_unit_failure do |error_internship_application|
        error_applications.push(error_internship_application)
      end
      on.success do |internship_offer|
        redirect_to internship_offer_path(internship_offer, anchor: 'internship-application-form'),
                    flash: { success: "Les candidature ont été soumises"}
      end
      on.failure do |internship_offer|
        redirect_to internship_offer_path(internship_offer, anchor: 'internship-application-form'),
                    flash: { error: "Toutes les candidature n'ont pas pu être soumises"}
      end
    end
  end

  # students can candidate for one internship_offer
  def create
    internship_application_builder.create_one(params: create_internship_application_params) do |on|
      on.success do |internship_application|
        redirect_to internship_offer_internship_application_path(internship_application.internship_offer,
                                                                 internship_application)
      end
      on.failure do |internship_application|
        @internship_application = internship_application
        render 'internship_offers/show', status: :bad_request
      end
    end
  end

  # school manager can destroy applications on reserved internship_offers
  def destroy
    @internship_application = @internship_offer.internship_applications.find(params[:id])
    authorize! :destroy, @internship_application
    @internship_application.destroy!
    redirect_to internship_offer_path(@internship_offer, anchor: 'internship-application-form'),
                flash: { success: "La candidature de #{@internship_application.student.name} a été supprimée"}
  rescue ActiveRecord::RecordInvalid => e
    flash[:error] = "La candidature de #{@internship_application.student.name} n'a pas été supprimée"
    render 'internship_application/show'
  end
  private

  def internship_application_builder
    @builder ||= Builders::InternshipApplicationBuilder.new(user: current_user,
                                                            internship_offer: @internship_offer)
  end
  def set_intership_applications
    @internship_applications = @internship_offer.internship_applications
                                                .order(updated_at: :desc)
                                                .page(params[:page])
  end

  def find_internship_offer
    @internship_offer = InternshipOffer.find(params[:internship_offer_id])
  end

  def update_internship_application_params
    params.require(:internship_application)
          .permit(
            :motivation
          )
  end
  def create_internship_application_params
    params.require(:internship_application)
          .permit(
            :motivation,
            :internship_offer_week_id,
            :user_id
          )
  end

  def bulk_create_internship_application_params
    params.require(:internship_application)
          .permit(
            :motivation,
            :internship_offer_week_id,
            student_ids: []
          )
  end
end
