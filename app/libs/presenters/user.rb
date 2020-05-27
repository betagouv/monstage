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
      "#{user.formal_name}"
    end

    def role_name
      user.human_attribute_name_for
    end

    def default_internship_offers_path
      return internship_offers_path if user.nil?
      return internship_offers_path unless user.respond_to?(:school)
      return internship_offers_path if user.school.nil?

      internship_offers_path(city: user.school.city,
                             latitude: user.school.coordinates.lat,
                             longitude: user.school.coordinates.lon,
                             radius: Nearbyable::DEFAULT_NEARBY_RADIUS_IN_METER)
    end

    private

    attr_reader :user
    def initialize(user)
      @user = user
    end
  end
end
