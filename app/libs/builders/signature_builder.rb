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
      code_checks
      user.check_and_expire_token!
      callback.on_success.try(:call, user.reload)
    rescue ActiveRecord::RecordInvalid => e
      callback.on_failure.try(:call, e.record)
    rescue ArgumentError => e
      callback.on_argument_error.try(:call, e)
    end

    def handwrite_sign
      yield callback if block_given?
      signatures = []

      # Signature.transaction do .... no : DON'T, because attachments will fail
      # see https://stackoverflow.com/questions/61484082/activestoragefilenotfounderror-activestoragefilenotfounderror-in-server-lo/71081755#71081755
      params[:agreement_ids].split(',').each do |internship_agreement_id|
        if user.already_signed?(internship_agreement_id: internship_agreement_id)
          user.errors.add(:id, 'Vous avez déjà signé cette convention')
          raise ActiveRecord::RecordInvalid, user
        end

        unless (internship_agreement_id !~ /\D+/)
          Rails.logger.error("internship_agreement_ids " \
                              "list is wrong : #{internship_agreement_id}")
        end

        signature = Signature.new(prepare_attributes(internship_agreement_id))

        unless user.signature_code_checked?
          signature.errors.add('id', 'Le code n\'a pas été validé ')
          raise ActiveRecord::RecordInvalid, signature
        end

        signature.attach_signature! &&
          signature.save! &&
          agreement_sign(signature.reload) &&
          signature.config_clean_local_signature_file &&
          signatures << signature
      end

      callback.on_success.try(:call, signatures)
    rescue ActiveRecord::RecordInvalid => e
      callback.on_failure.try(:call, e.record)
    rescue ArgumentError => e
      callback.on_argument_error.try(:call, e)
    end

    def prepare_attributes(internship_agreement_id)
      make_image(params: params,
                 internship_agreement_id: internship_agreement_id,
                 user: user) &&
        {
          internship_agreement_id: internship_agreement_id,
          signatory_role: user.signatory_role,
          signatory_ip: user.current_sign_in_ip,
          user_id: user.id,
          signature_phone_number: user.phone,
          signature_date: DateTime.now
        }
    end

    private

    attr_reader :callback, :user, :ability, :params

    def code_checks
      code = (0..5).inject([]) { |acc, i| acc << params["digit-code-target-#{i}".to_sym] }.join('')

      code_valid = user.code_valid?( code: code )
      raise ArgumentError, 'Erreur de code, veuillez recommencer' unless code_valid

      code_expired = user.code_expired?( code: code )
      raise ArgumentError, 'Code périmé, veuillez en réclamer un autre' if code_expired
    end

    def make_image(params:, internship_agreement_id: , user:)
      raise ArgumentError, 'Missing signature' if params[:signature_image].blank?

      signature_file_path = Signature.file_path(
        internship_agreement_id: internship_agreement_id,
        user: user
      )
      img = (params[:signature_image]).split(",")[1]
      img = Base64.decode64 img

      File.open(signature_file_path, "wb") { |f| f.write img } && true
    end

    def image_from(params:)
      img = (params[:signature_image]).split(",")[1]
      Base64.decode64 img
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
