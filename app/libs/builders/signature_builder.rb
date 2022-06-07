# frozen_string_literal: true

module Builders
  class Signature < BuilderBase
    def create(params:)
      yield callback if block_given?
      authorize :create, Signature # only school_managers and employers can create
      signature = Signature.new(prepare_attributes(params: params))
      signature.save!
      callback.on_success.try(:call, signature)
    rescue ActiveRecord::RecordInvalid => e
      callback.on_failure.try(:call, e.record)
    end

    def prepare_attributes(params:)
      {
        internship_agreement_id: params[:internship_aggreement_id],
        signatory_role: user.signatory_role,
        signatory_ip: user.current_sign_in_ip,
        signature_date: DateTime.now
      }
    end

    private

    attr_reader :callback, :user, :ability

    def initialize(user:, context:)
      @user = user
      @ability = Ability.new(user)
      @callback = Callback.new
      @context = context
    end
  end
end
