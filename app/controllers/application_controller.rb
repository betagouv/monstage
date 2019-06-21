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
    @current_weeks = Week.selectable_from_now_until_end_of_period
  end
end
