# frozen_string_literal: true

module Presenters
  class User
    delegate :application, to: Rails
    delegate :routes, to: :application
    delegate :url_helpers, to: :routes
    delegate :internship_offers_path, to: :url_helpers

    def short_name
      "#{user.first_name[0].capitalize}. #{user.last_name}"
    end

    def full_name
      "#{user.first_name} #{user.last_name}"
    end

    def formal_name
      user.formal_name.to_s
    end

    def role_name
      UserManagementRole.new(user: user).role
    end

    def default_internship_offers_path
      return internship_offers_path if user.nil? # TODO refactor?: should be able to use request.params[**] or user.default[**] or nothing
      return internship_offers_path unless user.respond_to?(:school) # TODO refactor?: should be able to use request.params[**] or user.default[**] or nothing
      return internship_offers_path if user.school.nil?# TODO refactor?: should be able to use request.params[**] or user.default[**] or nothing

      opts = user.school.default_search_options
      opts = opts.merge({school_track: user.try(:school_track)}) if user.try(:school_track)
      internship_offers_path(opts) # TODO refactor?: use pass thru url helper
    end

    private

    attr_reader :user
    def initialize(user)
      @user = user
    end
  end
end
