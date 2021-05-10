# frozen_string_literal: true

require 'forwardable'
module Presenters
  module Reporting
    class DimensionByEntreprise < BaseDimension
      ATTRS = %i[id
                 description
                 group_id
                 employer_name
                 human_max_candidates
                 published_at
                 discarded_at
                 submitted_applications_count
                 rejected_applications_count
                 approved_applications_count
                 department
                 academy
                 permalink
                 view_count].freeze
      METHODS = %i[group_name
                   human_is_public
                   human_category
                   sector_name
                   tutor_name
                   tutor_email
                   tutor_phone
                   full_employer
                   full_address
                   full_school
                   full_week].freeze

      def self.metrics
        [].concat(ATTRS, METHODS)
      end

      delegate(*ATTRS, to: :instance)

      def self.dimension_name
        "Titre de l'offre"
      end

      def human_max_candidates
        if instance.max_candidates == 1
          ' Stage individuel (un seul élève par stage)'
        else
          " Stage collectif (par groupe de #{instance.max_candidates} élèves)"
        end
      end

      def human_is_public
        instance.is_public ? 'Public' : 'Privé'
      end

      def human_category
        return 'Public' if instance&.group&.is_public

        instance.try(:group) ? 'PaQte' : 'Privé'
      end

      def group_name
        instance.group.try(:name) || 'Indépendant'
      end

      def total_report_count
        instance.total_report_count
      end
    end
  end
end
