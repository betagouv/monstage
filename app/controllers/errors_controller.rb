class ErrorsController < ApplicationController
  def page_not_found
    render status: 404
  end

  def unacceptable_request
    render status: 422
  end

  def server_error
    render status: 500
  end


end