# frozen_string_literal: true

module Presenters
  module Reporting
    class DimensionBySector < BaseDimension
      def self.metrics
        ::Reporting::InternshipOffer::AGGREGATE_FUNCTIONS.keys
      end
      delegate *self.metrics, to: :internship_offer

      def self.dimension_name
        'Secteur professionnel'
      end

      def dimension
        internship_offer.sector_name
      end
    end
  end
end
