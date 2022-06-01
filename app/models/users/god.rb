# frozen_string_literal: true

module Users
  class God < User
    def custom_dashboard_path
      url_helpers.rails_admin_path
    end

    def dashboard_name
      'Admin'
    end

    def presenter
      Presenters::God.new(self)
    end

    rails_admin do
      weight 8
    end
  end
end
