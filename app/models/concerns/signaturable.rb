module Signaturable
  extend ActiveSupport::Concern
  included do
    SIGNATURE_PHONE_TOKEN_VALIDITY = 2 # minutes

    def create_signature_phone_token
      return false if school_management? && !school_manager?

      update(signature_phone_token: format('%06d', rand(999_999)),
             signature_phone_token_validity: SIGNATURE_PHONE_TOKEN_VALIDITY.minute.from_now)
    end

    def signature_phone_confirmable?
      signature_phone_token.present? && signature_phone_token_still_ok?
    end

    def send_signature_sms_token
      return false unless phone.present?

      token_created = create_signature_phone_token
      message = "Votre code de signature : #{signature_presenter.show_code} " \
                "- Validité : #{SIGNATURE_PHONE_TOKEN_VALIDITY} minutes"
      token_created && SendSmsJob.perform_later(user: self, message: message) && true
    end

    def signature_phone_token_still_ok?
      Time.zone.now < signature_phone_token_validity
    end

    def expire_signature_token
      self.signature_phone_token_validity = Time.zone.now - 1.second
      save!
    end

    def nullify_phone_number
      self.phone = nil
      self.signature_phone_token_validity = nil
      self.phone_token_validity = nil
      save!
    end

    def allow_signature?(internship_agreement_id: , code:)
      return false if already_signed?(internship_agreement_id: internship_agreement_id)

      signature_phone_confirmable? && signature_phone_token == code
    end

    def obfuscated_phone_number
      phone.gsub(/(\+\d{2})(\d{1})(\d{1})(\d{6})(\d{2})/, '\1 \3 ** ** ** \5')
    end

    def signature_presenter
      @signature_presenter ||= Presenters::Signature.new(self)
    end
  end
end
