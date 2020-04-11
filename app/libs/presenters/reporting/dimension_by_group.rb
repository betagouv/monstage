# frozen_string_literal: true

require 'forwardable'
module Presenters
  module Reporting
    class DimensionByGroup < BaseDimension
      def self.metrics
        ::Reporting::InternshipOffer::AGGREGATE_FUNCTIONS.keys
      end
      delegate *metrics, to: :instance

      def self.dimension_name
        'Groupe ou Institution de tutelle'
      end

      def dimension
        instance.group.present? ?
          instance.group.name :
          'Indépendant'
      end
    end
  end
end
