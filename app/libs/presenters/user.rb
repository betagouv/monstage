# frozen_string_literal: true

module Presenters
  class User
    delegate :application, to: Rails
    delegate :routes, to: :application
    delegate :url_helpers, to: :routes
    delegate :internship_offers_path, to: :url_helpers
    delegate :default_search_options, to: :user

    def short_name
      "#{user.first_name[0].capitalize}. #{user.last_name}"
    end

    def full_name
      "#{user.first_name} #{user.last_name}"
    end

    def formal_name
      user.formal_name.to_s
    end

    def civil_name
      name = user.last_name.downcase.capitalize
      user.gender == "m" ? "Monsieur #{name}}" : "Madame #{name}}"
    end

    def role_name
      UserManagementRole.new(user: user).role
    end

    def default_internship_offers_path
      return internship_offers_path if user.nil?
      return internship_offers_path unless user.respond_to?(:school)
      return internship_offers_path if user.school.nil?

      internship_offers_path(default_search_options)
    end

    def pretty_phone_number
      return '' unless user.phone

      phone_number = user.phone.to_str
      phone_number = phone_number.gsub('+33', '0') if phone_number.start_with?("+33")
      phone_number.chars
                  .in_groups_of(2)
                  .map(&:join)
                  .join(' ')
    end

    private

    attr_reader :user
    def initialize(user)
      @user = user
    end
  end
end
