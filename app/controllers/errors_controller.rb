# frozen_string_literal: true

class ErrorsController < ApplicationController
  layout 'errorpage'
  skip_before_action :check_school_requested

  def not_found
    render status: 404
  end

  def unacceptable
    render status: 422
  end

  def internal_error
    render status: 500
  end
end

