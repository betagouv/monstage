# frozen_string_literal: true

module Presenters
  module Dashboard
    class StudentStats
      def applications_count
        student.internship_applications
               .size
      end

      def applications_approved_count
        student.internship_applications
               .select(&:approved?)
               .size
      end

      def applications_rejected_count
        student.internship_applications
               .select(&:rejected?)
               .size
      end

      def applications_with_convention_signed_count
        student.internship_applications
               .select(&:convention_signed?)
               .size
      end

      def internship_locations
        student.internship_applications
               .select(&:convention_signed?)
               .map(&:internship_offer)
               .map(&:formatted_autocomplete_address)
      end

      Tutor = Struct.new(:tutor_name,
                         :tutor_phone,
                         :tutor_email,
                         :tutor_role,
                         keyword_init: true)
      def internship_tutors
        student.internship_applications
               .select(&:convention_signed?)
               .map(&:internship_offer)
               .map do |internship_offer|
          Tutor.new(tutor_name: internship_offer.tutor_name,
                    tutor_phone: internship_offer.tutor_phone,
                    tutor_email: internship_offer.tutor_email,
                    tutor_role: internship_offer.tutor_role)
        end
      end

      private

      attr_reader :student
      def initialize(student:)
        @student = student
      end
    end
  end
end
