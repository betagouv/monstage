# frozen_string_literal: true

module Instrumentation
  # setup elatic apm context, see: https://www.elastic.co/guide/en/apm/agent/ruby/current/introduction.html
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
