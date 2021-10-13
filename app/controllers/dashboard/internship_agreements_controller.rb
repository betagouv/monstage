module Dashboard
  # WIP, not yet implemented, will host agreement signing
  class InternshipAgreementsController < ApplicationController
    before_action :authenticate_user!

    def new
      @internship_agreement = internship_agreement_builder.new_from_application(
        InternshipApplication.find(params[:internship_application_id])
      )
    end

    def create
      internship_agreement_builder.create(params: internship_agreement_params) do |on|
        on.success do |created_internship_agreement|
          redirect_to current_user.custom_agreements_path,
                      flash: { success: 'La convention a été créée.' }
        end
        on.failure do |failed_internship_agreement|
          @internship_agreement = failed_internship_agreement || InternshipAgreement.new(
            internship_application_id: params[:internship_application_id]
          )
          render :new, status: :bad_request
        end
      end
    rescue ActionController::ParameterMissing
      @internship_agreement = InternshipAgreement.new(
        internship_application_id: params[:internship_application_id]
      )
      render :new, status: :bad_request
    end

    def edit
      @internship_agreement = InternshipAgreement.find(params[:id])
      authorize! :update, @internship_agreement
    end

    def update
      internship_agreement_builder.update(instance: InternshipAgreement.find(params[:id]),
                                          params: internship_agreement_params) do |on|
        on.success do |updated_internship_agreement|
          updated_internship_agreement.send(params[:internship_agreement][:event]) if updated_internship_agreement.send("may_#{params[:internship_agreement][:event]}?")
          updated_internship_agreement.save
          redirect_to dashboard_internship_agreements_path,
                      flash: { success: 'La convention a été enregistrée.' }
        end
        on.failure do |failed_internship_agreement|
          @internship_agreement = failed_internship_agreement || InternshipAgreement.find(params[:id])
          render :edit
        end
      end
    rescue ActionController::ParameterMissing
      @internship_agreement = InternshipAgreement.find(params[:id])
      @available_weeks = Week.selectable_on_school_year
      render :edit
    end

    def show # TODO : test
      @internship_agreement = InternshipAgreement.find(params[:id])
      respond_to do |format|
        format.html
        format.pdf do
          send_data(GenerateInternshipAgreement.new(@internship_agreement.id).call.render, filename: "Convention_#{@internship_agreement.id}.pdf", type: 'application/pdf',disposition: 'inline')
        end
      end
    end

    def index
      @internship_agreements = current_user.internship_agreements
    end

    private

    def internship_agreement_params
      params.require(:internship_agreement)
            .permit(
              :internship_application_id,
              :student_school,
              :school_representative_full_name,
              :school_delegation_to_sign_delivered_at,
              :school_track,
              :student_full_name,
              :student_class_room,
              :main_teacher_full_name,
              :organisation_representative_full_name,
              :tutor_full_name,
              :date_range,
              :doc_date,
              :schedule_rich_text,
              :activity_scope_rich_text,
              :activity_preparation_rich_text,
              :complementary_terms_rich_text,
              :activity_learnings_rich_text,
              :activity_rating_rich_text,
              :legal_terms_rich_text,
              :school_manager_accept_terms,
              :employer_accept_terms,
              :main_teacher_accept_terms,
              :tutor_accept_terms,
              :weekly_lunch_break,
              weekly_hours:[],
              new_daily_hours:{},
              daily_lunch_break: {}
              )
    end

    def internship_agreement_builder
      @builder ||= Builders::InternshipAgreementBuilder.new(user: current_user)
    end
  end
end
