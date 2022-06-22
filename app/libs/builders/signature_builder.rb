# frozen_string_literal: true

module Builders
  class SignatureBuilder < BuilderBase
    def create
      yield callback if block_given?
      authorize :create, Signature # only school_managers and employers can create
      code = make_code_from_params
      if (user.signature_phone_token != code)
        raise ArgumentError, 'Erreur de code, veuillez recommencer'
      end
      unless user.allow_signature?(
        internship_agreement_id: params[:internship_agreeement_id],
        code: code
      )
        raise ArgumentError, 'Code périmé, veuillez vous en réclamer un autre'
      end
      signature = Signature.new(prepare_attributes)
      signature.save! && sign(signature)

      callback.on_success.try(:call, signature)
    rescue ActiveRecord::RecordInvalid => e
      callback.on_failure.try(:call, e.record)
    rescue ArgumentError => e
      callback.on_argument_error.try(:call, e)
    end

    def prepare_attributes
      {
        internship_agreement_id: params[:internship_agreement_id],
        signatory_role: user.signatory_role,
        signatory_ip: user.current_sign_in_ip,
        signature_date: DateTime.now,
        signature_phone_number: user.phone
      }
    end

    private

    attr_reader :callback, :user, :ability, :params

    def make_code_from_params
      (0..5).inject([]) {|acc, i| acc << params["digit-code-target-#{i}".to_sym] }
            .join('')
    end

    def sign(signature)
      internship_agreement = signature.internship_agreement
      if signature.all_signed?
        internship_agreement.signatures_finalize!
      else
        internship_agreement.sign!
      end
    end

    def initialize(user:, context:, params:)
      @user = user
      @ability = Ability.new(user)
      @params = params
      @callback = InternshipOfferCallback.new
      @context = context
    end
  end
end
