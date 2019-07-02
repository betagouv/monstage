# frozen_string_literal: true

module Api
  module Helpers
    extend ActiveSupport::Concern

    included do
      def capitalize_class_name(instance)
        instance.class.name.demodulize.underscore.upcase
      end

      def underscore_class_name(instance)
        instance.class.name.demodulize.underscore
      end
    end
  end
end
