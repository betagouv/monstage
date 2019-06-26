# frozen_string_literal: true

module Api
  module ResponseRenderer
    extend ActiveSupport::Concern

    included do
      def render_success(object:, status:)
        render json: object.to_json,
               status: status
      end

      def render_error(code:, error:, status:)
        render json: { code: code, error: error },
               status: status
      end

      def render_validation_error(instance)
        render_error(code: 'VALIDATION_ERROR',
                     error: instance.errors,
                     status: :bad_request)
      end

      def render_success_no_content
        head :no_content
      end
    end
  end
end
