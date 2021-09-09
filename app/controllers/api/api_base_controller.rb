# frozen_string_literal: true

module Api
  class ApiBaseController < ActionController::Base
    protect_from_forgery with: :null_session

    include Api::Helpers
    include Api::Authentication
    include Api::ResponseRenderer
    include Api::ErrorHandler
    include Api::DidYouMeanFormatter
  end
end
