# frozen_string_literal: true

module Builders
  # wrap internship offer creation logic / failure for API/web usage
  class InternshipOfferBuilder
    DEFAULT_SCHOOL_TYPE = :middle_school

    def create(params:)
      yield callback if block_given?
      authorize :create, model
      internship_offer = model.create!(preprocess_api_params(params, fallback_weeks: true))
      callback.on_success.try(:call, internship_offer)
    rescue ActiveRecord::RecordInvalid => e
      if duplicate?(e.record)
        callback.on_duplicate.try(:call, e.record)
      else
        callback.on_failure.try(:call, e.record)
      end
    end

    def update(instance:, params:)
      yield callback if block_given?
      authorize :update, instance
      instance.update!(preprocess_api_params(params, fallback_weeks: false))
      callback.on_success.try(:call, instance)
    rescue ActiveRecord::RecordInvalid => e
      callback.on_failure.try(:call, e.record)
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

    def preprocess_api_params(params, fallback_weeks:)
      return params unless from_api?

      params = add_defaults_to_params params

      opts = { params: params,
               user: user,
               fallback_weeks: fallback_weeks }

      Dto::ApiParamsAdapter.new(opts)
                           .sanitize
    end

    def from_api?
      context == :api
    end

    def model
      return ::InternshipOffers::Api if from_api?

      ::InternshipOffers::Web
    end

    def add_defaults_to_params(params)
      return params if params[:school_type]

      params.merge(school_type: DEFAULT_SCHOOL_TYPE)
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
