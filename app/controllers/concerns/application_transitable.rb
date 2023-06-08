module ApplicationTransitable
  extend ActiveSupport::Concern

  included do

    def update
      authorize! :update, @internship_application, InternshipApplication
      if valid_transition?
        @internship_application.send(params[:transition].to_sym)
        @internship_application.update!(optional_internship_application_params)
        extra_parameter = {tab: params[:transition]} if params[:transition].present?
        redirect_to current_user.custom_candidatures_path(extra_parameter),
                    flash: { success: update_flash_message }
      else
        redirect_back fallback_location: current_user.custom_dashboard_path,
                      flash: { success: 'Impossible de traiter votre requête, veuillez contacter notre support' }
      end
    rescue AASM::InvalidTransition => e
      redirect_back fallback_location: current_user.custom_dashboard_path,
                    flash: { warning: 'Cette candidature a déjà été traitée' }
    end

    protected

    def received_states
      %w[submitted read_by_employer examined expired]
    end

    def rejected_states
      %w[rejected canceled_by_employer canceled_by_student]
    end

    def approved_states
      %w[approved validated_by_employer]
    end

    def valid_states
        received_states + rejected_states + approved_states
    end

    def update_flash_message
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
                                               aasm_state])
            .fetch(:internship_application) { {} }
    end
  end
end