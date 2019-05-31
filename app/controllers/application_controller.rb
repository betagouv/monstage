# frozen_string_literal: true

class ApplicationController < ActionController::Base
  default_form_builder Rg2aFormBuilder

  rescue_from(CanCan::AccessDenied) do |_error|
    redirect_to(root_path,
                flash: { danger: "Vous n'êtes pas autorisé à effectuer cette action." })
  end

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || resource.after_sign_in_path || super
  end

  protected

  def find_selectable_weeks
    school_year = SchoolYear.new(date: Date.today)
    @current_weeks = Week.from_date_to_date(from: school_year.beginning_of_period,
                                            to: school_year.end_of_period)
  end
end
