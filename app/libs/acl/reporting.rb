# frozen_string_literal: true

module Acl
  class Reporting
    def allowed?
      user.department_name == params[:department]
    end

    def ministry_statistician_allowed?
      user.respond_to?(:ministries)
    end

    private

    attr_reader :params, :user
    def initialize(params:, user:)
      @params = params
      @user = user
    end
  end
end
