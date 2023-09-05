# frozen_string_literal: true

module Dashboard
  class InternshipApplicationsController < ApplicationController
    before_action :authenticate_user!

    def index
      authorize! :create, InternshipAgreement
      @internship_offer_areas = current_user.internship_offer_areas
      @internship_applications = current_user.internship_applications
                                             .filtering_discarded_students
                                             .approved

    end
  end
end
