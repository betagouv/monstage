# frozen_string_literal: true

module Builders
  # wrap internship offer creation logic / failure for API/web usage
  class InternshipOfferBuilder < BuilderBase
    # called by dashboard/stepper/practical_info#create during creating with steps
    def create_from_stepper(organisation:, internship_offer_info:, hosting_info:, practical_info:)
      yield callback if block_given?
      authorize :create, model
      internship_offer = model.new(
        {}.merge(preprocess_organisation_to_params(organisation))
          .merge(preprocess_internship_offer_info_to_params(internship_offer_info))
          .merge(preprocess_hosting_info_to_params(hosting_info))
          .merge(preprocess_practical_info_to_params(practical_info))
          .merge(employer_id: user.id, employer_type: 'User')
          .merge(
            organisation_id: organisation.id,
            internship_offer_info_id: internship_offer_info.id,
            hosting_info_id: hosting_info.id,
            practical_info_id: practical_info.id,
            internship_offer_area_id: user.current_area_id)
        )
        internship_offer.save!
        DraftedInternshipOfferJob.set(wait: 1.week)
                                 .perform_later(internship_offer_id: internship_offer.id)
        callback.on_success.try(:call, internship_offer)
      rescue ActiveRecord::RecordInvalid => e
        callback.on_failure.try(:call, e.record)
      end

    # called by internship_offers#create (duplicate), api/internship_offers#create
    def create(params:)
      yield callback if block_given?
      authorize :create, model
      preprocess_organisation(params)
      create_params = preprocess_api_params(params, **{fallback_weeks: true})
      internship_offer = model.create!(create_params)
      internship_offer.update(
        aasm_state: 'published',
        internship_offer_area_id: user.current_area_id)
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
      instance.attributes = preprocess_api_params(params, fallback_weeks: false)
      instance = deal_with_max_candidates_change(params: params, instance: instance)
      if from_api?
        instance.reset_publish_states
      elsif instance.may_publish? && instance.republish
        instance.publish!
      elsif instance.published_at.nil? && instance.may_unpublish?
        instance.unpublish!
      end
      instance.save! # this may set aasm_state to need_to_be_updated state
      deal_with_former_applications(instance: instance)
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
      callback.on_success.try(:call, instance)
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

      Dto::ApiParamsAdapter.new(**opts)
                           .sanitize
    end

    def preprocess_organisation_to_params(organisation)
      {
        employer_name: organisation.employer_name,
        employer_website: organisation.employer_website,
        employer_description_rich_text: organisation.employer_description,
        is_public: organisation.is_public,
        group_id: organisation.group_id,
        siret: organisation.siret,
        employer_manual_enter: organisation.manual_enter
      }
    end

    def preprocess_internship_offer_info_to_params(internship_offer_info)
      {
        sector_id: internship_offer_info.sector_id,
        title: internship_offer_info.title,
        description_rich_text: (internship_offer_info.description_rich_text.present? ? internship_offer_info.description_rich_text.to_s : internship_offer_info.description),
        type: 'InternshipOfferInfo'
      }
    end

    def preprocess_hosting_info_to_params(hosting_info)
      params = {
        max_candidates: hosting_info.max_candidates,
        max_students_per_group: hosting_info.max_students_per_group,
        school_id: hosting_info.school_id,
        type: 'InternshipOffers::WeeklyFramed'
      }
      params[:week_ids] = hosting_info.week_ids
      params
    end

    def preprocess_practical_info_to_params(practical_info)
      {
        weekly_hours: practical_info.weekly_hours,
        daily_hours: practical_info.daily_hours,
        lunch_break: practical_info.lunch_break,
        street: practical_info.street,
        zipcode: practical_info.zipcode,
        city: practical_info.city,
        coordinates: practical_info.coordinates,
        contact_phone: practical_info.contact_phone,
      }
    end

    def preprocess_organisation(params)
      return params unless params["organisation_attributes"]

      params["employer_name"] = params["organisation_attributes"]["employer_name"] unless params["organisation_attributes"]["employer_name"].blank?
      params["employer_website"] = params["organisation_attributes"]["employer_website"] unless params["organisation_attributes"]["employer_website"].blank?
      params["coordinates"] = params["organisation_attributes"]["coordinates"] unless params["organisation_attributes"]["coordinates"].blank?
      params["street"] = params["organisation_attributes"]["street"] unless params["organisation_attributes"]["street"].blank?
      params["zipcode"] = params["organisation_attributes"]["zipcode"] unless params["organisation_attributes"]["zipcode"].blank?
      params["city"] = params["organisation_attributes"]["city"] unless params["organisation_attributes"]["city"].blank?
      params["is_public"] = params["organisation_attributes"]["is_public"] unless params["organisation_attributes"]["is_public"].blank?
    end

    def from_api?
      context == :api
    end

    def deal_with_max_candidates_change(params: , instance: )
      return instance unless max_candidates_will_change?(params: params, instance: instance)

      approved_applications_count = instance.internship_applications.approved.count
      former_max_candidates = instance.max_candidates
      next_max_candidates = params[:max_candidates].to_i

      if next_max_candidates < approved_applications_count
        error_message = 'Impossible de réduire le nombre de places ' \
                        'de cette offre de stage car ' \
                        'vous avez déjà accepté plus de candidats que ' \
                        'vous n\'allez leur offrir de places.'
        instance.errors.add(:max_candidates, error_message)
        raise ActiveRecord::RecordInvalid, instance
      end

      instance
    end

    def type_will_change?(params: , instance: )
      params[:type] && params[:type] != instance.type
    end

    def max_candidates_will_change?(params: , instance: )
      params[:max_candidates] && params[:max_candidates] != instance.max_candidates
    end

    def model
      return ::InternshipOffers::Api if from_api?

      InternshipOffers::WeeklyFramed
    end

    def duplicate?(internship_offer)
      Array(internship_offer.errors.details[:remote_id])
        .map { |error| error[:error] }
        .include?(:taken)
    end

    def deal_with_former_applications(instance: )
      previous_week_ids_with_applications(instance: instance).each do |week_id|
        next if instance.week_ids.include?(week_id)

        instance.internship_applications
                .where(week_id: week_id)
                .each do |application|
          application.cancel_by_employer! if application.may_cancel_by_employer?
          # Deleting these applications which weeks were no longer in
          # the internship offer week list anymore leaded to jobs with missing
          # internship_application_id, see :
          # https://mon-stage-de-3e.sentry.io/issues/4685209330/?project=5933968&referrer=jira_integration
          # but keeping them lead to week orphaned applications weeks
          # after having tried the deleting approach, we decided to keep them
        end
      end
    end

    def previous_week_ids_with_applications(instance:)
      instance.internship_applications.map(&:week_id).uniq
    end
  end
end
