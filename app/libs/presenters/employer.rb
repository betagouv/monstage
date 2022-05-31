module Presenters
  class Employer < User
    def dashboard_name_link
      internship_offers_path
    end
  end
end
