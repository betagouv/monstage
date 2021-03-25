# frozen_string_literal: true

module Instrumentation
  # setup raven user context, see: https://docs.sentry.io/clients/ruby/integrations/#params-and-sessions
  module ElasticApm
    extend ActiveSupport::Concern

    included do
      before_action :set_elastic_apm_context, if: :current_user

      def set_elastic_apm_context
        ElasticAPM.set_user(current_user)
      end
    end
  end
end
