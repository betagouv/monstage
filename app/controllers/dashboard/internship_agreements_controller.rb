module Dashboard
  # WIP, not yet implemented, will host agreement signing
  class InternshipAgreementsController < ApplicationController

    def index
      authorize! :index, Acl::InternshipOfferDashboard.new(user: current_user)

      @internship_agreements = InternshipAgreement.all
    end

    def new
      authorize! :new, InternshipAgreement
      @internship_agreement = internship_agreement_builder.new_from_application(
        InternshipApplication.find(params[:internship_application_id])
      )
    end
    
    def create
      internship_agreement = InternshipAgreement.new(internship_agreement_params.merge({doc_date: Date.today}))
      authorize! :create, internship_agreement
      if internship_agreement.save
        redirect_to dashboard_internship_agreement_path(internship_agreement),
                      flash: { success: 'La convention a été créée.' }
      else
        @internship_offer = internship_agreement || InternshipAgreement.new(
          internship_application_id: params[:internship_application_id]
        )
        render :new, status: :bad_request
      end
    rescue ActionController::ParameterMissing
      @internship_offer = InternshipAgreement.new(
        internship_application_id: params[:internship_application_id]
      )
      render :new, status: :bad_request
    end

    def edit
      @internship_agreement = InternshipAgreement.find(params[:id])
      authorize! :update, @internship_agreement
    end

    def update
      internship_agreement = InternshipAgreement.find(params[:id])
      authorize! :update, internship_agreement
      if internship_agreement.update(internship_agreement_params)
        redirect_to dashboard_internship_agreement_path(internship_agreement),
                      flash: { success: 'La convention a été signée.' }
      else
        @internship_offer = internship_agreement || InternshipAgreement.find(params[:id])
        render :edit, status: :bad_request
      end
    rescue ActionController::ParameterMissing
      @internship_offer = InternshipAgreement.find(params[:id])
      render :edit, status: :bad_request
    end

    def show
      @internship_agreement = InternshipAgreement.find(params[:id])
    end

    private

    def internship_agreement_params
      params.require(:internship_agreement)
            .permit(
              :internship_application_id,
              :student_school,
              :school_representative_full_name,
              :student_full_name,
              :student_class_room,
              :main_teacher_full_name,
              :organisation_representative_full_name,
              :tutor_full_name,
              :start_date,
              :end_date,
              :doc_date,
              :schedule_rich_text,
              :activity_scope_rich_text,
              :activity_preparation_rich_text,
              :activity_schedule_rich_text,      
              :activity_learnings_rich_text,
              :activity_rating_rich_text,
              :housing_rich_text,
              :insurance_rich_text,
              :transportation_rich_text,
              :food_rich_text,
              :terms_rich_text)
    end

    def internship_agreement_builder
      @builder ||= Builders::InternshipAgreementBuilder.new(user: current_user)
    end
  end
end
