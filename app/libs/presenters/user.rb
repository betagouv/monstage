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
      "#{user.first_name.capitalize} #{user.last_name.capitalize}"
    end

    def formal_name
      "#{gender_text} #{user.first_name.try(:capitalize)} #{user.last_name.try(:capitalize)}"
    end

    def full_name_camel_case
      "#{user.first_name} #{user.last_name}".upcase.gsub(' ', '_')
    end

    def civil_name
      name = user.last_name.downcase.capitalize
      case user.gender
      when 'm'
        "Monsieur #{name}"
      when 'f'
        "Madame #{name}"
      else
        name
      end
    end

    def gender_text
      return 'Madame' if user.gender.eql?('f')
      return 'Monsieur' if user.gender.eql?('m')

      ''
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

    def dashboard_name_link
      url_helpers.root_path
    end

    protected

    attr_reader :user
    def initialize(user)
      @user = user
    end
  end
end
