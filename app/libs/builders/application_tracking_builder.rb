# frozen_string_literal: true

module Builders
  # wrap internship offer creation logic / failure for API/web usage
  class ApplicationTrackingBuilder < BuilderBase

    # called by application_trackings#create (duplicate), api/application_trackings#create
    def create(params:)
      yield callback if block_given?
      authorize :create, Api::ApplicationTracking
      create_params = preprocess_api_params(params: params)
      application_tracking = Api::ApplicationTracking.create!(create_params)
      callback.on_success.try(:call, application_tracking)
    rescue ActiveRecord::RecordInvalid => e
      if duplicate_instance?(e.record)
        callback.on_duplicate.try(:call, e.record)
      else
        callback.on_failure.try(:call, e.record)
      end
    rescue ArgumentError => e
      callback.on_argument_error.try(:call, e)
    end


    private

    attr_reader :callback, :user, :ability, :context

    def initialize(user:, context:)
      @user = user
      @context = context
      @ability = Ability.new(user)
      @callback = InternshipOfferCallback.new
    end

    def preprocess_api_params(params:)
      return params unless from_api?

      internship_offer = InternshipOffer.find_by(remote_id: params[:remote_id])
      if internship_offer.nil?
        raise ArgumentError, "remote_id: #{params[:remote_id]} is not valid"
      end

      fetch_student(params: params) && {
        internship_offer_id: internship_offer.id,
        student_id: params[:student_id],
        application_submitted_at: params[:remote_status] == 'application_submitted' ? DateTime.now : nil,
        application_approved_at: params[:remote_status] == 'application_approved' ? DateTime.now : nil,
        ms3e_student_id: params[:ms3e_student_id],
        remote_status: params[:remote_status]
      }
    end

    def fetch_student(params:)
      sent_id = params[:ms3e_student_id]
      if sent_id.present?
        arg_id = sent_id.match?(/\A\d+\z/) ? sent_id.to_i : 0
        student = User.find_by(id: arg_id)
        if student.nil?
          raise ArgumentError, "student_identification: #{sent_id} is not valid"
        end
      end
      params.merge!(student_id: student&.id)
    end

    def from_api?
      context == :api
    end

    def duplicate?(create_params:)
      rejected_keys = %i[
        ms3e_student_id
        application_submitted_at
        application_approved_at
      ]
      creation_parameters = create_params.reject { |k, _| k.in?(rejected_keys) }
      existing_application_tracking = ApplicationTracking.find_by(**creation_parameters)
      return false if existing_application_tracking.nil?

      raise ActiveRecord::RecordInvalid, existing_application_tracking
    end

    def duplicate_instance?(application_tracking)
      Array(application_tracking.errors.details[:internship_offer_id])
        .any? { |error| error[:error] == :taken }
    end
  end

end
