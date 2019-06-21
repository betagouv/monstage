module Api
  class ApiBaseController < ActionController::Base
    protect_from_forgery with: :null_session

    include Api::Authentication
    include Api::Renderer
  end
end
