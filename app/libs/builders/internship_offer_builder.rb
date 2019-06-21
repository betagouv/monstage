# frozen_string_literal: true

module Builders
  class InternshipOfferCallback < Callback
    attr_accessor :on_duplicate
    def duplicate(&block)
      @on_duplicate = block
    end
  end

  class InternshipOfferBuilder
    def create(params:)
      yield callback if block_given?
      authorize! :create, model
      params = from_api? ? preprocess_api_params(params) : params
      internship_offer = model.create!(params)
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
      authorize! :update, instance
      instance.update!(params)
      callback.on_success.try(:call, instance)
    rescue ActiveRecord::RecordInvalid => e
      callback.on_failure.try(:call, instance)
    end

    def discard(instance:)
      yield callback if block_given?
      authorize! :discard, instance
      instance.discard!
      callback.on_success.try(:call)
    rescue Discard::RecordNotDiscarded => e
      callback.on_failure.try(:call, instance)
    end

    private

    attr_reader :user, :callback, :ability, :context

    def initialize(user:, context:)
      @user = user
      @context = context
      @ability = Ability.new(user)
      @callback = InternshipOfferCallback.new
    end

    def preprocess_api_params(params)
      params = map_sector_uuid_to_sector(params: params)
      params = map_week_slugs_to_weeks(params: params)
      params = assign_offer_to_api_current_user(params: params)
      params
    end

    def from_api?
      context == :api
    end

    def model
      return ::Api::InternshipOffer if from_api?

      ::InternshipOffer
    end

    def map_sector_uuid_to_sector(params:)
      return params unless params.key?(:sector_uuid)

      params[:sector] = Sector.where(uuid: params.delete(:sector_uuid)).first
      params
    end

    def map_week_slugs_to_weeks(params:)
      if params.key?(:weeks)
        concatenated_query = nil
        Array(params.delete(:weeks)).map do |week_str|
          year, number = week_str.split('-W')
          base_query = Week.where(year: year, number: number)
          concatenated_query = concatenated_query.nil? ? base_query : concatenated_query.or(base_query)
        end
        params[:weeks] = concatenated_query.all
      else
        params[:weeks] = Week.selectable_from_now_until_end_of_period
      end
      params
    end

    def assign_offer_to_api_current_user(params:)
      params[:employer] = user
      params
    end

    def duplicate?(internship_offer)
      Array(internship_offer.errors.details[:remote_id]).map { |error| error[:error] }
                                                        .include?(:taken)
    end

    def authorize!(*vargs)
      return nil if ability.can?(*vargs)

      raise CanCan::AccessDenied
    end
  end
end
