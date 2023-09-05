
module Api
  class ApplicationTrackingsController < ApiBaseController
    before_action :authenticate_api_user!
    def create
      application_tracking_builder.create(params: create_application_tracking_params) do |on|
        on.success(&method(:render_created))
        on.failure(&method(:render_validation_error))
        on.duplicate(&method(:render_duplicate_tracking))
        on.argument_error(&method(:render_argument_error))
      end
    end

    private

    def render_duplicate_tracking(duplicate_ar_object)
      duplicate_specfics = duplicate_ar_object.attributes
                                              .compact
                                              .map { |k,v| "#{k} : #{v}"}
                                              .join(" | ")

      render_error(code: "DUPLICATE_#{capitalize_class_name(duplicate_ar_object)}",
                   error: "#{underscore_class_name(duplicate_ar_object)} with these attributes (#{duplicate_specfics}) already exists",
                   status: :conflict)
    end

    def application_tracking_builder
      @builder ||= Builders::ApplicationTrackingBuilder.new(user: current_api_user,
                                                            context: :api)
    end

    def create_application_tracking_params
      params.require(:application_tracking)
            .permit(
              :remote_id,
              :student_generated_id,
              :remote_status
            )
    end
  end
end
