# frozen_string_literal: true

require 'forwardable'
module Presenters
  module Reporting
    class DimensionByOffer < BaseDimension
      ATTRS = %i[title
                 description
                 max_candidates
                 internship_offer_weeks_count
                 is_public

                 created_at
                 discarded_at
                 published_at

                 coordinates

                 submitted_applications_count
                 rejected_applications_count
                 approved_applications_count
                 convention_signed_applications_count
                 total_applications_count

                 department
                 academy

                 permalink
                 view_count]
      METHODS = %i[group_name
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
        [internship_offer.school.name, "school.city – CP #{internship_offer.school.zipcode}"].compact.join("\n")
      end

      def full_weeks
        internship_offer.weeks.map(&:short_select_text_method).join("\n")
      end

    end
  end
end
