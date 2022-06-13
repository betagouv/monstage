module Dashboard
  module InternshipAgreements
    class UsersController < ApplicationController
      include Phonable

      def update
        authorize! :update, current_user
        if save_phone_user(current_user) && current_user.send_signature_sms_token
          @internship_agreement_id = params.permit[:internship_agreement_id]
          respond_to do |format|
            format.turbo_stream do
              id = params_for_code[:internship_agreement_id]
              render turbo_stream:
                turbo_stream.replace("internship-agreement-signature-form-#{id}",
                                      partial: 'dashboard/internship_agreements/signature/modal_code_submit_second',
                                      locals: {current_user: current_user,
                                               internship_agreement_id: id})
            end
            format.html do
              redirect_to confirm_code_dashboard_internship_agreements_user_path( id: current_user.id,
                                                               internship_agreement_id: params[:internship_agreement_id]),
                          notice: 'Votre code de signature vous a été envoyé par SMS'
            end
          end
        else
          redirect_to dashboard_internship_agreements_path,
                      alert: "Une erreur est survenue et le SMS n'a pas été envoyé"
        end
      end

      # one can use fetch_user_by_phone to get the user
      def sign
      end

      def confirm_code
      end


      def save_phone_user(user)
        return true if user.phone && user.phone == clean_phone_number
        return false if clean_phone_number.blank?

        user.update(phone: clean_phone_number)
      end

      def clean_phone_number
        params_for_code[:phone].try(:delete, ' ')
      end

      def params_for_code
        params.require(:user)
              .permit(:id,
                      :phone,
                      :internship_agreement_id)
      end
    end
  end
end
