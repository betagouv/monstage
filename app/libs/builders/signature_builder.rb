# frozen_string_literal: true

module Builders
  class SignatureBuilder < BuilderBase
    def post_signature_sms_token
      yield callback if block_given?
      authorize :create, Signature
      user.send_signature_sms_token
      callback.on_success.try(:call, user.reload)
    rescue ActiveRecord::RecordInvalid => e
      callback.on_failure.try(:call, e.record)
    rescue ArgumentError => e
      callback.on_failure.try(:call, e)
    end

    def signature_code_validate
      yield callback if block_given?
      authorize :create, Signature # only school_managers and employers can create

      if user.already_signed?(internship_agreement_id: params[:internship_agreement_id])
        user.errors.add(:id, 'Vous avez déjà signé cette convention')
        raise ActiveRecord::RecordInvalid, user
      end

      code = make_code_from_params
      code_expired = user.code_expired?(
        internship_agreement_id: params[:internship_agreeement_id],
        code: code
      )
      raise ArgumentError, 'Code périmé, veuillez en réclamer un autre' if code_expired

      code_valid = user.code_valid?(
        internship_agreement_id: params[:internship_agreeement_id],
        code: code
      )
      raise ArgumentError, 'Erreur de code, veuillez recommencer' unless code_valid

      user.check_and_expire_token!
      callback.on_success.try(:call, user.reload)
    rescue ActiveRecord::RecordInvalid => e
      callback.on_failure.try(:call, e.record)
    rescue ArgumentError => e
      callback.on_argument_error.try(:call, e)
    end

    def handwrite_sign
      yield callback if block_given?

      signature = Signature.new(prepare_attributes)
      signature.signature_image
               .attach(io: File.open("storage/signatures/#{signature.signature_file_name}"),
                       filename: signature.signature_file_name,
                       content_type: "image/png")
      unless user.signature_code_checked?
        signature.errors.add('id', 'Le code n\'a pas été validé ')
        raise ActiveRecord::RecordInvalid, signature
      end

      signature.save! &&
        agreement_sign(signature.reload) &&
        signature.clean_local_signature_file

      callback.on_success.try(:call, signature)
    rescue ActiveRecord::RecordInvalid => e
      callback.on_failure.try(:call, e.record)
    rescue ArgumentError => e
      callback.on_argument_error.try(:call, e)
    end

    def prepare_attributes
      make_image(params: params, user: user) &&
        File.readable?(temp_signature_file_path(params: params)) &&
        {
          internship_agreement_id: params[:internship_agreement_id],
          signatory_role: user.signatory_role,
          signatory_ip: user.current_sign_in_ip,
          user_id: user.id,
          signature_phone_number: user.phone,
          signature_date: DateTime.now
        }
    end

    private

    attr_reader :callback, :user, :ability, :params

    def make_code_from_params
      (0..5).inject([]) {|acc, i| acc << params["digit-code-target-#{i}".to_sym] }
            .join('')
    end

    def temp_signature_file_path(params: )
      image_name = "signature-#{Rails.env}" \
                   "-#{user.signatory_role}" \
                   "-#{params[:internship_agreement_id]}.png"
      "storage/signatures/#{image_name}"
    end

    def make_image(params:, user:)
      if params[:signature_image].blank?
        raise ArgumentError, 'Missing signature'
      end

      encoded_image = params[:signature_image].split(",")[1]
      decoded_image = Base64.decode64(encoded_image)
      image_name = "storage/signatures/signature-#{Rails.env}-" \
                   "#{user.signatory_role}-#{params[:internship_agreement_id]}.png"
      File.open(image_name, "wb") { |f| f.write(decoded_image) } && true
    end

    def agreement_sign(signature)
      internship_agreement = signature.internship_agreement
      if signature.all_signed?
        internship_agreement.signatures_finalize!
      else
        internship_agreement.sign!
      end
      true
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
