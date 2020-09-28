# frozen_string_literal: true

module Builders
  # wrap internship offer creation logic / failure for API/web usage
  class InternshipOfferBuilder

    # called by dashboard/stepper/tutor#create during creating with steps
    def create_from_stepper(tutor:, organisation:, internship_offer_info:)
      yield callback if block_given?
      authorize :create, model

      internship_offer = model.create!(
        {}.merge(preprocess_organisation_to_params(organisation))
          .merge(preprocess_internship_offer_info_to_params(internship_offer_info))
          .merge(preprocess_tutor_to_params(tutor))
          .merge(employer_id: user.id, employer_type: 'User')
          .merge(tutor: tutor, organisation: organisation, internship_offer_info: internship_offer_info)
      )
      callback.on_success.try(:call, internship_offer)
    rescue ActiveRecord::RecordInvalid => e
      callback.on_failure.try(:call, e.record)
    end

    # called by internship_offers#create (duplicate), api/internship_offers#create
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

      opts = { params: params,
               user: user,
               fallback_weeks: fallback_weeks }

      Dto::ApiParamsAdapter.new(opts)
                           .sanitize
    end

    def preprocess_organisation_to_params(organisation)
      {
        employer_name: organisation.name,
        employer_website: organisation.website,
        coordinates: organisation.coordinates,
        street: organisation.street,
        zipcode: organisation.zipcode,
        city: organisation.city,
        description: organisation.description,
        is_public: organisation.is_public,
        group_id: organisation.group_id,
      }
    end

    def preprocess_internship_offer_info_to_params(internship_offer_info)
      {
        title: internship_offer_info.title,
        description_rich_text: internship_offer_info.description_rich_text,
        max_candidates: internship_offer_info.max_candidates,
        school_id: internship_offer_info.school_id,
        first_date: internship_offer_info.first_date,
        last_date: internship_offer_info.last_date,
        weekly_hours: internship_offer_info.weekly_hours,
        daily_hours: internship_offer_info.daily_hours,
        sector_id: internship_offer_info.sector_id,
        type: internship_offer_info.type.gsub('Info', ''),
        week_ids: internship_offer_info.try(:weeks).try(:map) { |w| w.id }
      }
    end

    def preprocess_tutor_to_params(tutor)
      {
        tutor_name: tutor.tutor_name,
        tutor_email: tutor.tutor_email,
        tutor_phone: tutor.tutor_phone
      }
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
  end

end
