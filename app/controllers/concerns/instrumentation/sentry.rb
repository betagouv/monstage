# frozen_string_literal: true

module Instrumentation
  # setup raven user context, see: https://docs.sentry.io/clients/ruby/integrations/#params-and-sessions
  module Sentry
    extend ActiveSupport::Concern

    included do
      before_action :set_raven_context, if: :current_user

      def set_raven_context
        Raven.user_context(id: current_user.id)
      end
    end
  end
end
