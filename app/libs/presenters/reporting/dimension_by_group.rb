# frozen_string_literal: true

require 'forwardable'
module Presenters
  module Reporting
    class DimensionByGroup < BaseDimension
      def self.metrics
        ::Reporting::InternshipOffer::AGGREGATE_FUNCTIONS.keys
      end
      delegate *self.metrics, to: :internship_offer

      def self.dimension_name
        'Groupe ou Institution de tutelle'
      end

      def dimension
        internship_offer.group.present? ?
          internship_offer.group.name :
          'Indépendant'
      end
    end
  end
end
