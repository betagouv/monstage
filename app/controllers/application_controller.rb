# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include TurbolinkHelpers

  default_form_builder Rg2aFormBuilder

  rescue_from(CanCan::AccessDenied) do |_error|
    redirect_to(root_path,
                flash: { danger: "Vous n'êtes pas autorisé à effectuer cette action." })
  end

  def after_sign_in_path_for(resource)
    return resource.after_sign_in_path if resource.is_a?(Users::God)
    stored_location_for(resource) || resource.reload.after_sign_in_path || super
  end

  def current_user_or_visitor
    current_user || Users::Visitor.new
  end

  helper_method :user_presenter
  def user_presenter
    @user_presenter ||= Presenters::User.new(current_user_or_visitor)
  end
end
