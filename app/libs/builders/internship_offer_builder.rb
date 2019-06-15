module Builders
  class InternshipOfferBuilder < Callback
    SerializableError = Struct.new(:errors) do
    end

    def create(params:)
      yield callback if block_given?
      authorize! :create, InternshipOffer
      internship_offer = InternshipOffer.create!(preprocess_params(params))
      callback.on_success.try(:call, internship_offer)
    rescue ActiveRecord::RecordInvalid => error
      callback.on_failure.try(:call, error.record)
    end

    # # hard delete for operators
    # def destroy(remote_id:)
    #   authorize! :destroy, internship_offer
    # end

    # # soft delete for employers
    # def discard(internship_offer)
    #   authorize! :discard, internship_offer
    # end

    private
    attr_reader :user, :callback, :ability

    def preprocess_params(params)
      params = params.call
      params[:sector] = preprocess_sector(sector: params.delete(:sector_uuid)) if from_api?(params)
      params[:weeks] = preprocess_week(weeks: params.delete(:weeks)) if from_api?(params)
      params
    end

    def from_api?(params)
      params.key?(:sector_uuid)
    end

    def preprocess_sector(sector_uuid:)
      Sector.where(uuid: sector_uuid).first
    end

    def preprocess_week(weeks:)
      query_weeks = weeks.map do |week_str|
        year, number = week.split("W")
        { year: year, number: number }
      end
      Week.where(query_weeks).all
    end

    def authorize!(*vargs)
      return nil if ability.can?(*vargs)
      fail CanCan::AccessDenied
    end

    def initialize(user:)
      @user = user
      @ability = Ability.new(user)
      @callback = Callback.new
    end
  end
end
