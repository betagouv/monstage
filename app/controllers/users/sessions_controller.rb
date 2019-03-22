# frozen_string_literal: true

module Users
  class SessionsController < Devise::SessionsController
    after_action :remove_notice, only: [:destroy, :create]

    private

    def remove_notice
      flash[:notice] = nil
    end
  end
end
