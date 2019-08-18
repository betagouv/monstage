# frozen_string_literal: true

module Builders
  class InternshipApplicationBuilder
    def create_one(params:)
      yield callback if block_given?
      authorize! :apply, internship_offer
      internship_application = InternshipApplication.create!(params)
      callback.on_success.try(:call, internship_application)
    rescue ActiveRecord::RecordInvalid => error
      callback.on_failure.try(:call, error.record)
    end

    def create_many(params:)
      yield callback if block_given?
      @success_applications = @error_applications = []
      success = true
      authorize! :apply_in_bulk, internship_offer

      params[:student_ids].compact
                          .reject { |student_id| student_id == '0' }
                          .map do |student_id|
        unit_params = params.except(:student_ids)
                            .merge(user_id: student_id)
        internship_application = InternshipApplication.new(unit_params)

        if %i[save submit! approve!].map { |m| internship_application.send(m) }.all?
          @success_applications.push(internship_application)
        else
          success = false
          @error_applications.push(internship_application)
        end
      end

      if success
        callback.on_success.try(:call, internship_offer)
      else
        callback.on_failure.try(:call, internship_offer)
      end
    end

    def success_message
      "Les candidature (#{@success_applications.map(&:student_name).join(', ')}) ont été soumises"
    end

    def error_message
      errors = @error_applications.map do |internship_application|
        [
          internship_application.student_name,
          internship_application.errors
                                .messages
                                .map { |_key, errors_message| errors_message }
                                .join(', ')
        ].join(': ')
      end
      "Les candidature (#{errors.join(', ')}) n'ont pas pu être soumises"
    end

    private

    attr_reader :callback, :user, :ability, :internship_offer

    def initialize(user:, internship_offer:)
      @user = user
      @internship_offer = internship_offer
      @ability = Ability.new(user)
      @callback = Callback.new
    end

    def authorize!(*vargs)
      return nil if ability.can?(*vargs)

      raise CanCan::AccessDenied
    end
  end
end
