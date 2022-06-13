module Signaturable
  extend ActiveSupport::Concern
  included do
    def create_signature_phone_token
      return if school_management? && !school_manager?

      update(phone_token: format('%06d', rand(999_999)),
             phone_token_validity: 2.minute.from_now)
    end

    def send_signature_sms_token
      return unless phone.present?

      create_signature_phone_token
      message = "Votre code de signature : #{self.phone_token} - valide pendant 2 minutes"
      # SendSmsJob.perform_later(user: self, message: message) TODO : uncomment at commit time
    end

    def already_signed?(internship_agreement_id:)
      Signature.already_signed?(
        user_role: signatory_role,
        internship_agreement_id: internship_agreement_id
      )
    end

    def signs(internship_agreement_id:, code: )
      return unless allow_signature?(internship_agreement_id: internship_agreement_id, code: code)

      Signature.create(
        user_role: signatory_role,
        internship_agreement_id: internship_agreement_id
      )
    end

    def allow_signature?(internship_agreement_id: , code:)
      return false if already_signed?(internship_agreement_id: internship_agreement_id)

      phone_confirmable? && phone_token == code
    end

    def obfuscated_phone_number
      phone.gsub(/(\+\d{2})(\d{1})(\d{1})(\d{6})(\d{2})/, '\1 \3 ** ** ** \5')
    end
  end
end