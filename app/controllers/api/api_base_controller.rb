module Api
  class ApiBaseController < ActionController::Base
    protect_from_forgery with: :null_session

    def render_success(object:, status:)
      render json: object.to_json,
             status: status
    end

    def render_error(code:, error:, status:)
      render json: { code: code, error: error },
             status: status
    end

    def render_validation_error(instance)
      render_error(code: "VALIDATION_ERROR",
                   error: instance.errors,
                   status: :bad_request)
    end

    private

    def bearer
      request.env['Authorization'] || params[:token]
    end

    def token
      bearer && bearer.split("Bearer ")[1]
    end

    def current_api_user
      query = Users::Operator.where(api_token: token)
      @current_api_user ||= query.first
    end

    def authenticate_api_user!
      return render_error(code: "UNAUTHORIZED", error: "wrong api token", status: :unauthorized) unless current_api_user
    end
  end
end
