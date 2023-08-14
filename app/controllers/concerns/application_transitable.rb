module ApplicationTransitable
  extend ActiveSupport::Concern

  included do

    def update
      authenticate_user! unless params[:sgid].present? || params[:token].present?
      authorize_through_sgid? || authorize_through_token? || authorize!(:update, @internship_application)
      if valid_transition?
        @internship_application.send(params[:transition].to_sym)
        @internship_application.update!(optional_internship_application_params)
        extra_parameter = {tab: params[:transition]}
        if authorize_through_sgid? || authorize_through_token?
          reset_session
          redirect_to root_path,
                      flash: { success: update_flash_message }
        else
          redirect_to current_user.custom_candidatures_path(extra_parameter),
                      flash: { success: update_flash_message }
        end
      else
        redirect_back fallback_location: current_user.custom_dashboard_path,
                      flash: { success: 'Impossible de traiter votre requête, veuillez contacter notre support' }
      end
    rescue AASM::InvalidTransition => e
      redirect_back fallback_location: current_user ? current_user.custom_dashboard_path || root_path : root_path,
                    flash: { warning: 'Cette candidature a déjà été traitée' }
    end

    def authorize_through_sgid?
      return false unless params[:sgid].present?

      sgid_internship_application = InternshipApplications::WeeklyFramed.from_sgid(params[:sgid])
      sgid_internship_application&.id == @internship_application.id
    end

    def authorize_through_token?
      return false unless params[:token].present?
      @internship_application.access_token == params[:token]
    end

    protected

    def valid_states
        InternshipApplication.received_states +
          InternshipApplication.rejected_states +
          InternshipApplication.approved_states
    end

    def update_flash_message
      current_user = authorize_through_sgid? ? @internship_application.student : @current_user
      case
      when @internship_application.reload.read_by_employer? || @internship_application.examined?
        "Candidature mise à jour."
      when @internship_application.rejected?
        "Candidature refusée."
      when @internship_application.approved?
        current_user.employer? ? "Candidature mise à jour avec succès. #{extra_message}" : "Candidature acceptée !"
      else
        'Candidature mise à jour avec succès.'
      end
    end

    def valid_transition?
      %w[
        submit!
        read!
        examine!
        employer_validate!
        approve!
        reject!
        cancel_by_employer!
        cancel_by_student!
      ].include?(params[:transition])
    end

    def optional_internship_application_params
      params.permit(internship_application: %i[examined_message
                                               approved_message
                                               canceled_by_employer_message
                                               canceled_by_student_message
                                               rejected_message
                                               type
                                               aasm_state
                                               sgid])
            .fetch(:internship_application) { {} }
    end
  end
end
