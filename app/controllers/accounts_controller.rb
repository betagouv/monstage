class AccountsController < ApplicationController
  before_action :find_selectable_weeks, only: [:edit, :update]
  before_action :authenticate_user!

  def index
  end
end
