module TurbolinkHelpers
  extend ActiveSupport::Concern

  included do
    helper_method :turbolink_cache_disabled?

    def turbolink_cache_disabled?
      @disable_turbolink_caching
    end

    def disable_turbolink_caching
      @disable_turbolink_caching = true
    end

  end
end
