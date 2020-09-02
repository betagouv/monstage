# frozen_string_literal: true

module Builders
  # wrap internship offer creation logic / failure for API/web usage
  class InternshipOfferBuilder
    def create(params:)
      yield callback if block_given?
      authorize :create, model
      params = concat_params(params)
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

      InternshipOffer
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

    def concat_params(params)
      info = InternshipOfferInfo.find(params[:internship_offer_info_id])
      organisation = Organisation.find(params[:organisation_id])
      organisation_params = {
        employer_name: organisation.name,
        street: organisation.street,
        zipcode: organisation.zipcode,
        city: organisation.city,
        employer_website: organisation.website,
        description: organisation.description,
        coordinates: organisation.coordinates,
        is_public: organisation.is_public,
        group_id: organisation.group_id,
        employer_id: manage_employer(organisation.id),
        employer_type: 'User'
      }
      internship_offer_info_params = {
        title: info.title,
        description_rich_text: info.description_rich_text,
        max_candidates: info.max_candidates,
        school_id: info.school_id,
        first_date: info.first_date,
        last_date: info.last_date,
        weekly_hours: info.weekly_hours,
        daily_hours: info.daily_hours,
        sector_id: info.sector_id,
        type: info.type.gsub('Info', ''),
        week_ids: info.weeks.map(&:id)
      }

      params.merge(organisation_params).merge(internship_offer_info_params)
    end

    def manage_employer(organisation_id)
      @user.is_a?(Users::Employer) ? @user.id : organisation_id
    end
  end

end
