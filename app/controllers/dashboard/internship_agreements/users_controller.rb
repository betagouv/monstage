module Dashboard
  module InternshipAgreements
    class UsersController < ApplicationController
      include Phonable
      before_action :fetch_internship_agreement, only:[:sign, :resend_sms_code]

      def update
        authorize! :update, current_user
        if save_phone_user(current_user) && current_user.send_signature_sms_token
          @internship_agreement_id = params.permit[:internship_agreement_id]
          respond_to do |format|
            format.turbo_stream do
              id = user_params[:internship_agreement_id]
              path = 'dashboard/internship_agreements/signature/modal_code_submit_second'
              render turbo_stream:
                turbo_stream.replace("internship-agreement-signature-form-#{id}",
                                      partial: path,
                                      locals: {current_user: current_user,
                                               internship_agreement_id: id})
            end
          end
        else
          redirect_to dashboard_internship_agreements_path,
                      alert: "Une erreur est survenue et le SMS n'a pas été envoyé"
                      # status: :unprocessable_entity,
        end
      end

      def reset_phone_number
        authorize! :update, current_user
        if current_user.nullify_phone_number
          redirect_to dashboard_internship_agreements_path(opened_modal: true),
                      notice: 'Votre numéro de téléphone a été supprimé'
        else
          redirect_to dashboard_internship_agreements_path,
                      alert: "Une erreur est survenue et " \
                             "votre demande n'a pas été traitée"
        end
      end

      def resend_sms_code
        authorize! :resend_sms_code, @internship_agreement
        if current_user.send_signature_sms_token
          respond_to do |format|
            format.turbo_stream do
              flash_path = 'dashboard/internship_agreements/signature/flash_new_code'
              render turbo_stream:
                turbo_stream.replace("code-request",
                                    partial: flash_path,
                                    locals: { notice: 'Un nouveau code a été envoyé'})
            end
          end
        else
          err_msg = "Une erreur est survenue et votre demande n'a pas été traitée"
          redirect_to dashboard_internship_agreements_path,
                      status: :unprocessable_entity,
                      alert: err_msg
        end
      end

      def sign
        authorize! :sign, @internship_agreement
        signature_builder.create do |on|
          on.success do |signature|
            redirect_to dashboard_internship_agreements_path,
                        notice: 'Votre signature a été enregistrée'
          end
          on.failure do |error|
            redirect_to dashboard_internship_agreements_path,
                        alert: error.errors.full_messages
          end
          on.argument_error do |error_msg|
            redirect_to dashboard_internship_agreements_path,
                        alert: error_msg
          end
        end
      end

      private

      def save_phone_user(user)
        return true if user.phone && user.phone == clean_phone_number
        return false if clean_phone_number.blank?

        user.update(phone: clean_phone_number)
      end

      def clean_phone_number
        user_params[:phone].try(:delete, ' ')
      end

      def signature_builder
        @signature_buider = Builders::SignatureBuilder.new(
          user: current_user,
          context: :web,
          params: user_params
        )
      end

      def user_params
        allowed_params = %i[id phone internship_agreement_id]
        allowed_params += (0..5).map {|i| "digit-code-target-#{i}".to_sym}
        params.require(:user).permit(*allowed_params)
      end

      def fetch_internship_agreement
        @internship_agreement = InternshipAgreement.find(params[:internship_agreement_id])
      end
    end
  end
end