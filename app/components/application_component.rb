
class ApplicationComponent < ViewComponent::Base
  delegate :application, to: Rails
  delegate :routes, to: :application
  delegate :url_helpers, to: :routes

end
