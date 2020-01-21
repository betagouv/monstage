# frozen_string_literal: true

require 'forwardable'
module Presenters
  module Reporting
    class DimensionByOffer < BaseDimension
      ATTRS = %i[description
                 human_max_candidates
                 internship_offer_weeks_count

                 discarded_at
                 published_at

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
                   full_school
                   full_weeks]


      def self.metrics
        [].concat(ATTRS, METHODS)
      end


      delegate *ATTRS, to: :internship_offer

      def self.dimension_name
        "Titre de l'offre"
      end

      def human_max_candidates
        internship_offer.max_candidates == 1 ?
          " Stage individuel (un seul élève par stage)" :
          " Stage collectif (par groupe de #{internship_offer.max_candidates} élèves)"
      end

      def human_is_public
        internship_offer.is_public ? 'Public' : 'Privé'
      end

      def dimension
        internship_offer.title
      end

      def sector_name
        internship_offer.sector.name
      end

      def group_name
        internship_offer.group.try(:name) || 'Indépendant'
      end

      def full_tutor
        [internship_offer.tutor_name, internship_offer.tutor_email, internship_offer.tutor_phone].compact.join("\n")
      end

      def full_employer
        [internship_offer.employer_name, internship_offer.employer_website, internship_offer.employer_description].compact.join("\n")
      end

      def full_address
        [internship_offer.street, internship_offer.zipcode, internship_offer.city].compact.join("\n")
      end

      def full_school
        return nil unless internship_offer.school
        [internship_offer.school.name, "#{internship_offer.school.city} – CP #{internship_offer.school.zipcode}"].compact.join("\n")
      end

      def full_weeks
        internship_offer.weeks
                        .map(&:long_select_text_method)
                        .join("\n")
      end
    end
  end
end
