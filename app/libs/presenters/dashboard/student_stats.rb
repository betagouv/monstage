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

      def applications_best_status
        applications = student.internship_applications
        if applications.empty?
          return {color: 'warning', label: 'doit faire des candidatures'}
        end

        apps_status = applications.map(&:aasm_state)
        rejected_status = %w[rejected canceled_by_employer canceled_by_student cancel_by_student_confirmation]
        pending_status = %w[submitted read_by_employer examined]
        if  "approved".in?(apps_status)
          { color: 'success', label: 'Stage accepté' }
        elsif "validated_by_employer".in?(apps_status)
          { color: 'new', label: "Confirmer la venue dans l'entreprise" }
        elsif ( pending_status & apps_status).present?
          { color: 'info', label: 'en attente de réponse' }
        elsif "expired".in?(apps_status)
          { color: 'error ', label: 'candidature expirée' }
        elsif (rejected_status & apps_status).present?
          { color: 'error', label: 'candidature refusée' }
        else
          { color: 'grey', label: "en attente" }
        end
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
