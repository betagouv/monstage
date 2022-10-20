module Builders
  # wrap internship offer creation logic / failure for API/web usage
  class OperatorAccountActivityBuilder < BuilderBase
    def create_account(params:)
      yield callback if block_given?
      authorize :notify_account_was_created, OperatorActivity
      remote_account = OperatorActivity.create!(preprocess_api_params(params))
      callback.on_success.try(:call, remote_account)
    rescue ActiveRecord::RecordInvalid => e
      if duplicate?(e.record)
        callback.on_duplicate.try(:call, e.record)
      else
        callback.on_failure.try(:call, e.record)
      end
    rescue ArgumentError => e
      callback.on_argument_error.try(:call, e)
    end

    private

    attr_reader :user, :ability, :context, :callback

    def initialize(user:, context:)
      @user = user
      @context = context
      @ability = Ability.new(user)
      @callback = InternshipOfferCallback.new
    end

    def preprocess_api_params(params)
      params.merge!(student_id: params.delete(:student_id))
      params.merge!(operator_id: params.delete(:remote_id))
      params.merge!(account_created: true)
    end

    def duplicate?(record)
      record.errors[:account_created].any?
    end
  end
end
