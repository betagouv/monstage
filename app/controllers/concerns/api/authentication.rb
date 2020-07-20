# frozen_string_literal: true

module Api
  module Authentication
    extend ActiveSupport::Concern

    included do
      private

      def bearer
        request.headers['Authorization'] || params[:token]
      end

      def token
        bearer && bearer.split('Bearer ')[1]
      end

      def current_api_user
        query = Users::Operator.where(api_token: token)
        @current_api_user ||= query.first
      end

      def authenticate_api_user!
        render_error(code: 'UNAUTHORIZED', error: 'wrong api token', status: :unauthorized) unless current_api_user
      end
    end
  end
end
