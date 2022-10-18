module Api
  class RemoteAccountController < ApiBaseController
    before_action :authenticate_api_user!

    def account_create
      account_builder.create(params: create_remote_account_params) do |on|
        on.success(&method(:render_created))
        on.failure(&method(:render_validation_error))
        on.duplicate(&method(:render_duplicate))
        on.argument_error(&method(:render_argument_error))
      end
    end

    private

    def account_builder
      @builder ||= Builders::RemoteAccountBuilder.new(user: current_api_user,
                                                      context: :api)
    end

    def create_remote_account_params
      params.require(:remote_account)
            .permit(:monstage_user_id)
    end
  end
end