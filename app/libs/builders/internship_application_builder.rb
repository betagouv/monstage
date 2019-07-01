# frozen_string_literal: true

module Builders
  class InternshipApplicationCallback < Callback
    attr_accessor :on_bulk_unit_failure,
                  :on_bulk_unit_success
    def bulk_unit_failure(&block)
      @on_bulk_unit_failure = block
    end
    def bulk_unit_success(&block)
      @on_bulk_unit_success = block
    end
  end

  class InternshipApplicationBuilder
    def create_one(params:)
      yield callback if block_given?
      authorize! :apply, internship_offer
      internship_application = InternshipApplication.create!(params)
      callback.on_success.try(:call, internship_application)
    rescue ActiveRecord::RecordInvalid => e
      callback.on_failure.try(:call, e.record)
    end

    def create_many(params:)
      yield callback if block_given?
      success = true
      authorize! :apply_in_bulk, internship_offer
      internship_applications = []
      student_ids = params[:student_ids].dup
      student_ids.map do |student_id|
        next if student_id.blank?
        begin
          next if InternshipApplication.exists?(user_id: student_id, internship_offer_week_id: Week.find(params[:internship_offer_week_id]))
          unit_params = params.except(:student_ids)
                              .merge(user_id: student_id)
                              .merge(aasm_state: :approved)
          internship_application = InternshipApplication.new(unit_params)
          if internship_application.save
          callback.on_bulk_unit_success.try(:call, internship_application)
          else
            success = false
            callback.on_bulk_unit_failure.try(:call, internship_application)
          end
        end
      end

      if success
        callback.on_success.try(:call, internship_offer)
      else
        callback.on_failure.try(:call, internship_offer)
      end
    end

    private

    attr_reader :callback, :user, :ability, :internship_offer

    def initialize(user:, internship_offer:)
      @user = user
      @internship_offer = internship_offer
      @ability = Ability.new(user)
      @callback = InternshipApplicationCallback.new
    end

    def authorize!(*vargs)
      return nil if ability.can?(*vargs)

      raise CanCan::AccessDenied
    end
  end
end
