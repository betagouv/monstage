# frozen_string_literal: true

module Dto
  # adapt api params to model
  class ApiParamsAdapter
    def sanitize
      check_street
      check_zipcode
      check_location_enter_mode
      map_sector_uuid_to_sector
      map_week_slugs_to_weeks
      assign_offer_to_current_api_user
      params
    end

    private

    attr_reader :params, :user, :fallback_weeks
    def initialize(params:, user:, fallback_weeks:)
      @params = params
      @user = user
      @fallback_weeks = fallback_weeks
    end

    def map_sector_uuid_to_sector
      return params unless params.key?(:sector_uuid)

      params[:sector] = Sector.where(uuid: params.delete(:sector_uuid)).first
      params
    end

    def map_week_slugs_to_weeks
      # if params[:weeks] is empty, validation error will be raised when persisting
      if params.key?(:weeks) && params[:weeks].present?
        concatenated_query = nil
        Array(params.delete(:weeks)).map do |week_str|
          year, number = week_str.split('-W')
          base_query = Week.where(year: year, number: number)
          raise ArgumentError, "bad week format: #{week_str}, expecting ISO 8601 format" if base_query.blank?

          concatenated_query = concatenated_query.nil? ? base_query : concatenated_query.or(base_query)
        end
        params[:weeks] = concatenated_query.all
      elsif fallback_weeks
        params[:weeks] = Week.selectable_from_now_until_end_of_school_year
      end
      params
    end

    def assign_offer_to_current_api_user
      params[:employer] = user
      params
    end

    def check_street
      if params[:street].blank? && params[:coordinates].present?
        params[:street] = Geofinder.street(params[:coordinates]['latitude'], params[:coordinates]['longitude']) || 'N/A'
      end
      params
    end

    def check_zipcode
      if params[:zipcode].blank? && params[:coordinates].present?
        params[:zipcode] = Geofinder.zipcode(params[:coordinates]['latitude'], params[:coordinates]['longitude']) || 'N/A'
      end
      params
    end

    def check_location_enter_mode
      params[:location_manual_enter] = "from_api"
      params
    end
  end
end
