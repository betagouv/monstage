# frozen_string_literal: true

require 'forwardable'
module Presenters
  module Reporting
    class DimensionByOffer < BaseDimension
      ATTRS = %i[description
                 human_max_candidates
                 published_at
                 discarded_at
                 submitted_applications_count
                 rejected_applications_count
                 approved_applications_count
                 department
                 academy
                 permalink
                 view_count]
      METHODS = %i[group_name
                   human_is_public
                   sector_name
                   full_tutor
                   full_employer
                   full_address
                   full_school]
                   # full_weeks


      def self.metrics
        [].concat(ATTRS, METHODS)
      end


      delegate *ATTRS, to: :instance

      def self.dimension_name
        "Titre de l'offre"
      end

      def human_max_candidates
        instance.max_candidates == 1 ?
          " Stage individuel (un seul élève par stage)" :
          " Stage collectif (par groupe de #{instance.max_candidates} élèves)"
      end

      def human_is_public
        instance.is_public ? 'Public' : 'Privé'
      end

      def dimension
        instance.title
      end

      def sector_name
        instance.sector.name
      end

      def group_name
        instance.group.try(:name) || 'Indépendant'
      end

      def full_tutor
        [instance.tutor_name, instance.tutor_email, instance.tutor_phone].compact.join("\n")
      end

      def full_employer
        [instance.employer_name, instance.employer_website, instance.employer_description].compact.join("\n")
      end

      def full_address
        Address.new(instance: instance).to_s
      end

      def full_school
        return nil unless instance.school
        [instance.school.name, "#{instance.school.city} – CP #{instance.school.zipcode}"].compact.join("\n")
      end

      # def full_weeks
      #   WeekList.new(weeks: instance.weeks).to_s
      # end
    end
  end
end
