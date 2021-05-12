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
        group_name
      end

      def human_category
        return 'Public' if instance&.group&.is_public

        instance.try(:group) ? 'PaQte' : 'Privé'
      end

      def group_name
        instance.group.try(:name) || 'Indépendant'
      end
    end
  end
end
