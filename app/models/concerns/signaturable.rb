module Signaturable
  extend ActiveSupport::Concern
  included do
    def create_signature_phone_token
      return if school_management? && !school_manager?

      update(phone_token: format('%06d', rand(999_999)),
             phone_token_validity: 1.minute.from_now)
    end

    def send_signature_sms_token
      return unless phone.present?

      create_signature_phone_token
      message = "Votre code de signature : #{self.phone_token} - valide pendant 1 minute"
      SendSmsJob.perform_later(user: self, message: message)
    end

    def already_signed?(internship_agreement_id:)
      Signature.already_signed?(
        user_role: signatory_role,
        internship_agreement_id: internship_agreement_id
      )
    end

    def signs(internship_agreement_id:)
      unless already_signed?(internship_agreement_id: internship_agreement_id)
        Signature.create(
          user_role: signatory_role,
          internship_agreement_id: internship_agreement_id
        )
      end
    end

    def allow_signature?(code:)
      return false unless phone_confirmable?

      phone_token == code
    end
  end
end