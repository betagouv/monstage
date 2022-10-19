module Api
  class PartnerAccountActivitiesController < ApiBaseController
    before_action :authenticate_api_user!

    def create_account
      account_builder.create_account(params: create_remote_account_params) do |on|
        on.success(&method(:render_created))
        on.duplicate(&method(:render_duplicate))
        on.failure(&method(:render_validation_error))
        on.argument_error(&method(:render_argument_error))
      end
    end

    private

    def account_builder
      @builder ||= Builders::PartnerAccountActivityBuilder.new(user: current_api_user,
                                                                     context: :api)
    end

    def create_remote_account_params
      params.permit(:student_id, :remote_id)
    end
  end
end
