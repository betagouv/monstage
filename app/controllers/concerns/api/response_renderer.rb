# frozen_string_literal: true

module Api
  module ResponseRenderer
    extend ActiveSupport::Concern

    included do
      DUPLICATE_FIELDS = {
        OperatorActivity: :operator_id
      }

      #
      # base responders
      #
      def render_success(object:, status:, json_options:{})
        render json: object.to_json(json_options),
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
        duplicate_field = duplicate_fields(duplicate_ar_object)
        error_message = "#{underscore_class_name(duplicate_ar_object)} with " \
                        "this remote_id (#{duplicate_ar_object.send(duplicate_field)}) " \
                        "already exists"
        render_error(code: "DUPLICATE_#{capitalize_class_name(duplicate_ar_object)}",
                     error: error_message,
                     status: :conflict)
      end

      def render_validation_error(invalid_ar_object)
        render_error(code: 'VALIDATION_ERROR',
                     error: invalid_ar_object.errors,
                     status: :bad_request)
      end

      def render_discard_error(discard_ar_object)
        render_error(code: "#{capitalize_class_name(discard_ar_object)}_ALREADY_DESTROYED",
                     error: "#{underscore_class_name(discard_ar_object)} already destroyed",
                     status: :conflict)
      end

      def render_argument_error(error)
        render_error(code: "BAD_ARGUMENT",
                     error: error.to_s,
                     status: :unprocessable_entity)
      end

      def render_not_authorized
        render_error(code: 'UNAUTHORIZED', 
                     error: 'access denied', 
                     status: :unauthorized)
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

      private

      def duplicate_fields(duplicate_ar_object)
        DUPLICATE_FIELDS.fetch(duplicate_ar_object.class.name.to_sym, :remote_id)
      end
    end
  end
end
