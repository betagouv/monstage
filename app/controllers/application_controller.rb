# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Turbo::Redirection

  helper Turbo::FramesHelper if Rails.env.test?
  helper Turbo::StreamsHelper if Rails.env.test?

  before_action :check_school_requested

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

  helper_method :user_presenter, :current_user_or_visitor
  def user_presenter
    @user_presenter ||= Presenters::User.new(current_user_or_visitor)
  end

  private

  def check_school_requested
    if current_user && current_user.missing_school?
      redirect_to account_path(:school), flash: {warning: 'Veuillez choisir un établissement scolaire'}
    end
  end

  # use with trace :my_var, binding
  def trace(sym_var, binding)
    require 'pretty_console'
    var_value = eval(sym_var.to_s, binding)
    puts " "
    puts_in_orange_loudly " ---------------------------- "
    puts_in_green_loudly "#{sym_var} = #{var_value}"
    puts_in_orange_loudly " ---------------------------- "
    puts " "
  end
end
