# frozen_string_literal: true

module Api
  module ErrorHandler
    extend ActiveSupport::Concern

    included do
      rescue_from(ActionController::ParameterMissing) do |error|
        render_error(code: 'BAD_PAYLOAD',
                     error: error.message,
                     status: :unprocessable_entity)
      end

      rescue_from(CanCan::AccessDenied) do |error|
        render_error(code: 'FORBIDDEN',
                     error: error.message,
                     status: :forbidden)
      end

      rescue_from(ActiveRecord::RecordNotFound) do |error|
        render_error(code: 'NOT_FOUND',
                     error: "can't find #{error.model.demodulize.underscore} with this remote_id",
                     status: :not_found)
      end
    end
  end
end
