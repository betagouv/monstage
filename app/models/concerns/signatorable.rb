module Signatorable
  extend ActiveSupport::Concern
  included do
    SIGNATURE_PHONE_TOKEN_LIFETIME ||= 2 # minutes

    def create_signature_phone_token
      return false if school_management? && !school_manager?

      update(signature_phone_token: format('%06d', rand(999_999)),
             signature_phone_token_validity: SIGNATURE_PHONE_TOKEN_LIFETIME.minutes.from_now)
      # update(signature_phone_token: format('%06d', 111_111),
      #        signature_phone_token_validity: SIGNATURE_PHONE_TOKEN_LIFETIME.minutes.from_now)
    end

    def send_signature_sms_token
      return false unless phone.present?

      token_created = create_signature_phone_token
      message = "Votre code de signature : #{show_code} " \
                "- Validité : #{SIGNATURE_PHONE_TOKEN_LIFETIME} minutes"
      token_created && SendSmsJob.perform_later(user: self, message: message) && true
      # true
    end

    def nullify_phone_number!
      self.phone                          = nil
      self.signature_phone_token_validity = nil
      self.phone_token_validity           = nil
      save!
    end

    def check_and_expire_token!
      self.signature_phone_token_checked_at = Time.zone.now
      self.signature_phone_token_validity   = Time.zone.now - 1.second
      save!
    end

    def signature_role
      return 'employer' if employer?
      return 'school_manager' if school_manager?
    end

    def signature_code_checked?
      time_check = signature_phone_token_checked_at
      return if time_check.nil?

      validity = signature_phone_token_validity
      duration = SIGNATURE_PHONE_TOKEN_LIFETIME.minutes

      validity - duration < time_check
    end

    def code_expired?(internship_agreement_id: , code:)
      signature_phone_token.nil? ||
        !signature_phone_token_still_ok?
    end

    def code_valid?(internship_agreement_id: , code:)
      signature_phone_token.present? &&
        signature_phone_token == code
    end

    def signature_phone_token_still_ok?
      Time.zone.now < signature_phone_token_validity
    end

    def other_roles_than_mine
      Signature.signatory_roles.keys - [signatory_role]
    end

    def obfuscated_phone_number
      phone.gsub(/(\+\d{2})(\d{1})(\d{1})(\d{6})(\d{2})/, '\1 \3 ** ** ** \5')
    end

    def show_code
      return "" if signature_phone_token.nil?

      [signature_phone_token[0..2], signature_phone_token[3..-1]].join(' ')
    end
  end
end
