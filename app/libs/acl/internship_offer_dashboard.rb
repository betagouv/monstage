# frozen_string_literal: true

module Acl
  class InternshipOfferDashboard
    def allowed?
      return true if user.employer?
      return true if user.operator?

      false
    end

    private

    attr_reader :user
    def initialize(user:)
      @user = user
    end
  end
end
