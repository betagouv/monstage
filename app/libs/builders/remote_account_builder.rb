module Builders
  # wrap internship offer creation logic / failure for API/web usage
  class RemoteAccountBuilder < BuilderBase
    def create(params:)
      yield callback if block_given?
      authorize :create, model
      remote_account = model.create!(preprocess_api_params(params))
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
  end
end
