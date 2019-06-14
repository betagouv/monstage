module Builders
  class InternshipOfferBuilder < Callback

    def create(params:)
      yield callback if block_given?
      authorize! :create, InternshipOffer
      internship_offer = InternshipOffer.new(params.call)

      if internship_offer.save
        callback.on_success.try(:call, internship_offer)
      else
        callback.on_failure.try(:call, internship_offer)
      end
    rescue ActiveRecord::RecordInvalid,
           ActionController::ParameterMissing => e
      callback.on_failure.try(:call)
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
