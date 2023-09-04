
module Api
  class ApplicationTrackingsController < ApiBaseController
    before_action :authenticate_api_user!
    def create
      application_tracking_builder.create(params: create_application_tracking_params) do |on|
        on.success(&method(:render_created))
        on.failure(&method(:render_validation_error))
        on.duplicate(&method(:render_duplicate))
        on.argument_error(&method(:render_argument_error))
      end
    end

    def update ; end
    def destroy ; end

    private

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
