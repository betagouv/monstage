# frozen_string_literal: true

module Acl
  class InternshipOfferDashboard
    def allowed?
      return true if user.is_a?(Users::Employer)
      return true if user.is_a?(Users::Operator)

      false
    end

    private

    attr_reader :user
    def initialize(user:)
      @user = user
    end
  end
end
