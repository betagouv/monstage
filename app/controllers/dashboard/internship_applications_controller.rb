# frozen_string_literal: true

module Dashboard
  class InternshipApplicationsController < ApplicationController
    before_action :authenticate_user!

    def index
      authorize! :create, InternshipAgreement
      @internship_applications = current_user.internship_applications
                                             .approved

    end
  end
end
