# frozen_string_literal: true

class InternshipApplicationsController < ApplicationController
  before_action :persist_login_param, only: %i[new]
  before_action :authenticate_user!, except: %i[update]
  before_action :set_internship_offer

  def index
    set_intership_applications
    authorize! :read, @internship_offer
    authorize! :index, InternshipApplication
  end

  def new
    authorize! :apply, @internship_offer
    @internship_application = InternshipApplication.new(
      internship_offer_id: params[:internship_offer_id],
      internship_offer_type: 'InternshipOffer',
      student: current_user)
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
      redirect_to completed_internship_offer_internship_application_path(@internship_offer, @internship_application)
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

    @internship_application = InternshipApplication.create!({user_id: current_user.id}.merge(create_internship_application_params))
    redirect_to internship_offer_internship_application_path(@internship_offer,
                                                             @internship_application)
  rescue ActiveRecord::RecordInvalid => e
    @internship_application = e.record
    puts @internship_application.errors.messages
    render 'new', status: :bad_request
  end

  def completed
    set_internship_offer
    @internship_application = @internship_offer.internship_applications.find(params[:id])
    authorize! :submit_internship_application, @internship_application

    @suggested_offers = Finders::InternshipOfferConsumer.new(
      params: {
        latitude: @internship_application.student.school.coordinates.latitude,
        longitude: @internship_application.student.school.coordinates.longitude,
        week_ids: [@internship_application.week_id]
      },
      user: current_user_or_visitor
    ).all.includes([:sector]).order(id: :desc).last(6)
  end

  def edit_transfer
    @internship_application = InternshipApplication.find(params[:id])
    authorize! :transfer, @internship_application
  end

  def transfer
    @internship_application = InternshipApplication.find(params[:id])
    authorize! :transfer, @internship_application
    # send email to the invited employer
    if params[:destinations].present?
      @internship_application.update(aasm_state: :examined)
      @internship_application.generate_token

      params[:destinations].split(',').each do |destination|
        EmployerMailer.transfer_internship_application(
          internship_application: @internship_application, 
          employer_id: current_user.id,
          email: destination,
          message: params[:comment]).deliver_now unless destination.blank?
      end
    end

    redirect_to dashboard_internship_offer_internship_application_path(@internship_application.internship_offer, @internship_application), flash: { success: "La candidature a été transmise avec succès, son statut est à l'étude" }
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
              email
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
            :type,
            :week_id,
            :internship_offer_id,
            :internship_offer_type,
            :motivation,
            :student_phone,
            :student_email,
            student_attributes: %i[
              email
              phone
              resume_educational_background
              resume_other
              resume_languages
            ]
          )
  end

  def persist_login_param
    session[:as] = params[:as]
  end
end
