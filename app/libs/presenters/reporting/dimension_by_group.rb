# frozen_string_literal: true

require 'forwardable'
module Presenters
  module Reporting
    class DimensionByGroup < BaseDimension
      def self.metrics
        ::Reporting::InternshipOffer::AGGREGATE_FUNCTIONS.keys
      end
      delegate(*metrics, to: :instance)
      delegate :group_id, to: :instance

      def self.dimension_name
        'Groupe ou Institution de tutelle'
      end

      def dimension
        instance.group.try(:name) || 'Indépendant'
      end
      alias group_name dimension

      def human_category
        return 'Public' if instance&.group&.is_public
        return 'PaQte' if instance&.group&.is_paqte

        'Privé'
      end
    end
  end
end
