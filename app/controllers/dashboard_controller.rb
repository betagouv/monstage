class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    redirect_to current_user.custom_dashboard_path
  end
end
