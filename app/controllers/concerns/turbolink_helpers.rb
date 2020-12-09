module TurbolinkHelpers
  extend ActiveSupport::Concern

  included do
    helper_method :turbolink_disabled_to_force_page_refresh?

    def turbolink_disabled_to_force_page_refresh?
      @disable_turbolink_caching_to_force_page_refresh
    end

    def disable_turbolink_caching_to_force_page_refresh
      @disable_turbolink_caching_to_force_page_refresh = true
    end

  end
end
