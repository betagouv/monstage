# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Instrumentation::ElasticApm
  include TurbolinkHelpers

  default_form_builder Rg2aFormBuilder

  rescue_from(CanCan::AccessDenied) do |_error|
    redirect_to(root_path,
                flash: { danger: "Vous n'êtes pas autorisé à effectuer cette action." })
  end

  def after_sign_in_path_for(resource)
    return resource.after_sign_in_path if resource.is_a?(Users::God)

    stored_location_for(resource) || resource.after_sign_in_path || super
  end

  def current_user_or_visitor
    current_user || Users::Visitor.new
  end

  def resource_channel
    return current_user.channel unless current_user.nil?
    return :email unless params[:as] == 'Student'

    ab_test(:subscription_channel_experiment) do |chan|
      chan == 'phone' ? :phone : :email
    end
    # when ab_test is over, remove method and replace resource_channel
    # with: resource.channel directly in the views
  end

  helper_method :user_presenter
  def user_presenter
    @user_presenter ||= Presenters::User.new(current_user_or_visitor)
  end
end
