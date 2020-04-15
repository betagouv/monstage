# frozen_string_literal: true

module Presenters
  module Reporting
    class DimensionBySchool < BaseDimension
      ATTRS = %i[department
                 code_uai
                 human_kind].freeze
      METHODS = %i[total_student_count
                   total_main_teacher_count
                   total_approved_internship_applications_count
                   human_school_manager
                   full_address
                   full_weeks].freeze

      def self.metrics
        [].concat(ATTRS, METHODS)
      end

      delegate *metrics, to: :instance

      def self.dimension_name
        'Etablissement'
      end

      def human_school_manager
        instance.school_manager ? 'Inscrit' : 'Non Inscrit'
      end

      def dimension
        instance.name
      end

      def human_kind
        Presenters::SchoolKind.new(kind: instance.kind).to_s
      end

      def full_address
        Address.new(instance: instance).to_s
      end

      def full_weeks
        WeekList.new(weeks: instance.weeks).to_range_as_str
      end

      private

      attr_reader :instance
      def initialize(instance)
        @instance = instance
      end
    end
  end
end
