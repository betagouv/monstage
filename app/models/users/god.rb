# frozen_string_literal: true

module Users
  class God < User
    def custom_dashboard_path
      url_helpers.rails_admin_path
    end

    def dashboard_name
      'Admin'
    end
  end
end
