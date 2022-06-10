module Dashboard
  module InternshipAgreements
    class UsersController < ApplicationController
      include Phonable

      def update
        if save_phone_user(current_user) && true # current_user.send_signature_sms_token
          redirect_to dashboard_internship_agreements_path,
                      notice: 'Votre code de signature vous a été envoyé par SMS'
        else
          redirect_to dashboard_internship_agreements_path,
                      alert: "Une erreur est survenue et le SMS n'a pas été envoyé"
        end
      end

      # one can use fetch_user_by_phone to get the user

      def save_phone_user(user)
        return true if user.phone && user.phone == safe_phone_param

        user.update(phone: safe_phone_param)
      end
    end
  end
end
