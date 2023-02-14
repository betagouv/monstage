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

    def show_when_subscribe?(as: , field:)
      common_fields = %i[
        first_name
        last_name
        email
        password
        password_confirmation
        accept_terms
      ]
      return true if field.in?(common_fields)
      return true if field.in?(subscribe_fields(as: as))
      
      false
    end

    def subscription_incipit(as:)
      case as
      when :employer
        "Déposez vos offres de stages à l'aide de votre compte personnalisé. " \
        "Il vous permettra à tout moment de modifier vos offres et de " \
        "suivre leur avancement."
      when :statistician
        "Vous êtes référent départemental et souhaitez accéder aux " \
        "statistiques relatives aux offres de stage de votre département."
      else
        ''
      end
    end

    def subscribe_fields(as:)
      case as
      when :student
        %i[gender email phone school_id class_room_id birth_date handicap_present handicap]
      when :employer
        %i[email employer_role]
      when :school_management
        %i[email school_id class_room_id role]
      else
        []
      end
    end

    protected

    attr_reader :user
    def initialize(user)
      @user = user
    end
  end
end
