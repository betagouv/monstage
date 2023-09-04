# frozen_string_literal: true

module Builders
  # wrap internship offer creation logic / failure for API/web usage
  class InternshipOfferBuilder < BuilderBase

    # called by internship_offers#create (duplicate), api/internship_offers#create
    def create(params:)
      yield callback if block_given?
      authorize :create, ApplicationTracking
      # preprocess_tracking_informations(params)
      create_params = preprocess_api_params(params)
      internship_offer = ApplicationTracking.create!(create_params)
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

    # def update(instance:, params:)
    #   yield callback if block_given?
    #   authorize :update, instance
    #   instance.publish! if instance.republish
    #   instance.attributes = preprocess_api_params(params, fallback_weeks: false)
    #   instance = deal_with_max_candidates_change(params: params, instance: instance)
    #   instance.save!
    #   callback.on_success.try(:call, instance)
    # rescue ActiveRecord::RecordInvalid => e
    #   callback.on_failure.try(:call, e.record)
    # rescue ArgumentError => e
    #   callback.on_argument_error.try(:call, e)
    # end


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

      internship_offer = InternshipOffer.find_by(remote_id: params[:remote_id])
      raise ArgumentError, "remote_id: #{params[:remote_id]} is not valid" if internship_offer.nil?
      fetch_student && {
        internship_offer_id: internship_offer.id,
        student_id: params[:student_id],
        student_identifier: params[:student_id] || params[:student_generated_id],
        remote_status: params[:remote_status]
      }
    end

    def fetch_student
      sent_id = params[:student_generated_id]
      student = nil
      if sent_id.present? && sent_id.starts_with?('ms3e')
        student = User.find_by(student_identification: sent_id.split('ms3e').last)
        if student.nil?
          raise ArgumentError, "student_identification: #{sent_id} is not valid"
        end
      end
      params.merge!(student_id: student&.id)
    end


    def from_api?
      context == :api
    end

    def duplicate?(internship_offer)
      Array(internship_offer.errors.details[:remote_id])
        .map { |error| error[:error] }
        .include?(:taken)
    end
  end

end
