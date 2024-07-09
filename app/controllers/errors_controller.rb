# frozen_string_literal: true

class ErrorsController < ApplicationController
  layout 'errorpage'
  skip_before_action :check_school_requested

  def not_found
    respond_to do |format|
      format.html { render status: 404 }
      format.json { render json: { error: 'Page non trouvée' }, status: 404 }
    end
  end

  def not_acceptable
    respond_to do |format|
      format.html { render status: 406 }
      format.json { render json: { error: 'Requête non acceptée' }, status: 406 }
    end
  end

  def bad_request
    render status: 400
  end

  def unacceptable
    render status: 422
  end

  def internal_error
    render status: 500
  end
end

