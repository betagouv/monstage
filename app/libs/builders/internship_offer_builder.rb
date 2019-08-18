# frozen_string_literal: true

module Builders
  # wrap internship offer creation logic / failure for API/web usage
  class InternshipOfferBuilder
    def create(params:)
      yield callback if block_given?
      authorize :create, model
      internship_offer = model.create!(preprocess_api_params(params))
      callback.on_success.try(:call, internship_offer)
    rescue ActiveRecord::RecordInvalid => error
      if duplicate?(error.record)
        callback.on_duplicate.try(:call, error.record)
      else
        callback.on_failure.try(:call, error.record)
      end
    end

    def update(instance:, params:)
      yield callback if block_given?
      authorize :update, instance
      instance.update!(preprocess_api_params(params))
      callback.on_success.try(:call, instance)
    rescue ActiveRecord::RecordInvalid => error
      callback.on_failure.try(:call, error.record)
    end

    def discard(instance:)
      yield callback if block_given?
      authorize :discard, instance
      instance.discard!
      callback.on_success.try(:call)
    rescue Discard::RecordNotDiscarded
      callback.on_failure.try(:call, instance)
    end

    private

    attr_reader :callback, :user, :ability, :context

    def initialize(user:, context:)
      @user = user
      @context = context
      @ability = Ability.new(user)
      @callback = InternshipOfferCallback.new
    end

    def preprocess_api_params(params)
      return params unless from_api?

      Dto::ApiParamsAdapter.new(params: params, user: user)
                           .sanitize
    end

    def from_api?
      context == :api
    end

    def model
      return ::Api::InternshipOffer if from_api?

      ::InternshipOffer
    end

    def duplicate?(internship_offer)
      Array(internship_offer.errors.details[:remote_id])
        .map { |error| error[:error] }
        .include?(:taken)
    end

    def authorize(*vargs)
      return nil if ability.can?(*vargs)

      raise CanCan::AccessDenied
    end
  end
end
