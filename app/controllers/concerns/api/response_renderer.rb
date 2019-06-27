# frozen_string_literal: true

module Api
  module ResponseRenderer
    extend ActiveSupport::Concern

    included do
      #
      # base responders
      #
      def render_success(object:, status:)
        render json: object.to_json,
               status: status
      end

      def render_error(code:, error:, status:)
        render json: { code: code, error: error },
               status: status
      end

      #
      # error renderers
      #
      def render_duplicate(duplicate_ar_object)
        render_error(code: "DUPLICATE_#{duplicate_ar_object.capitalize_class_name}",
                     error: "#{duplicate_ar_object.underscore_class_name} with this remote_id (#{duplicate_ar_object.remote_id}) already exists",
                     status: :conflict)
      end

      def render_validation_error(invalid_ar_object)
        render_error(code: 'VALIDATION_ERROR',
                     error: invalid_ar_object.errors,
                     status: :bad_request)
      end

      def render_discard_errror(discard_ar_object)
        render_error(code: "#{discard_ar_object.capitalize_class_name}_ALREADY_DESTROYED",
                     error: "#{discard_ar_object.underscore_class_name} already destroyed",
                     status: :conflict)
      end

      #
      # success renderers
      #
      def render_created(created_ar_object)
        render_success(status: :created, object: created_ar_object)
      end

      def render_ok(updated_ar_object)
        render_success(status: :ok, object: updated_ar_object)
      end

      def render_no_content
        head :no_content
      end
    end
  end
end
