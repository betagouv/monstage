# frozen_string_literal: true

module Builders
  # wrap internship offer creation logic / failure for API/web usage
  class InternshipOfferBuilder < BuilderBase
    # called by dashboard/stepper/tutor#create during creating with steps
    def create_from_stepper(tutor:, organisation:, internship_offer_info:)
      yield callback if block_given?
      authorize :create, model
      internship_offer = model.new(
        {}.merge(preprocess_organisation_to_params(organisation))
          .merge(preprocess_internship_offer_info_to_params(internship_offer_info))
          .merge(preprocess_tutor_to_params(tutor))
          .merge(employer_id: user.id, employer_type: 'User')
          .merge(tutor_id: tutor.id, organisation_id: organisation.id, internship_offer_info_id: internship_offer_info.id)
      )
      internship_offer.save!
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
    rescue ArgumentError => e
      callback.on_argument_error.try(:call, e)
    end

    def update(instance:, params:)
      yield callback if block_given?
      authorize :update, instance
      if type_will_change?(params: params, instance: instance)
        instance = switch_type(instance: instance, params: params)
      end
      instance.attributes = preprocess_api_params(params, fallback_weeks: false)
      instance.save!
      callback.on_success.try(:call, instance)
    rescue ActiveRecord::RecordInvalid => e
      callback.on_failure.try(:call, e.record)
    rescue ArgumentError => e
      callback.on_argument_error.try(:call, e)
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

      # API default school_track parameter is set by default
      # in postgres with :troisieme generale
      opts = { params: params,
               user: user,
               fallback_weeks: fallback_weeks }

      Dto::ApiParamsAdapter.new(opts)
                           .sanitize
    end

    def preprocess_organisation_to_params(organisation)
      {
        employer_name: organisation.employer_name,
        employer_website: organisation.employer_website,
        coordinates: organisation.coordinates,
        street: organisation.street,
        zipcode: organisation.zipcode,
        city: organisation.city,
        employer_description_rich_text: organisation.employer_description,
        is_public: organisation.is_public,
        group_id: organisation.group_id,
        siret: organisation.siret,
      }
    end

    def preprocess_internship_offer_info_to_params(internship_offer_info)
      params = {
        title: internship_offer_info.title,
        description_rich_text: (internship_offer_info.description_rich_text.present? ? internship_offer_info.description_rich_text.to_s : internship_offer_info.description),
        max_candidates: internship_offer_info.max_candidates,
        max_students_per_group: internship_offer_info.max_students_per_group,
        school_id: internship_offer_info.school_id,
        weekly_hours: internship_offer_info.weekly_hours,
        new_daily_hours: internship_offer_info.new_daily_hours,
        sector_id: internship_offer_info.sector_id,
        school_track: internship_offer_info.school_track,
        type: internship_offer_info.type.gsub('Info', ''),
      }
      params[:week_ids] = internship_offer_info.week_ids if internship_offer_info.weekly?
      params
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

    def switch_type(instance:, params:)
      if instance.with_applications?
        error_message = 'Impossible de modifier la filière de ' \
                        'cette offre de stage car ' \
                        'vous avez au moins une candidature pour cette offre.'
        instance.errors.add(:type, error_message)
        raise ActiveRecord::RecordInvalid, instance
      end
      instance.becomes!(params[:type].constantize)
    end

    def type_will_change?(params: , instance: )
      params[:type] && params[:type] != instance.type
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
  end

end
