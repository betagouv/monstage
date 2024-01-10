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
      # TODO remove following method
      def applications_with_convention_signed_count
        student.internship_applications
               .select(&:convention_signed?)
               .size
      end

      def internship_locations
        student.internship_applications
               .select(&:approved?)
               .map(&:internship_offer)
               .map(&:formatted_autocomplete_address)
      end

      def applications_best_status
        states_hash= {
          must_apply: {color: 'warning', label: 'doit faire des candidatures'},
          expired: { color: 'error ', label: 'candidature expirée' },
          canceled: { color: 'error', label: "candidature annulée par l'élève"},
          rejected: { color: 'error', label: 'candidature refusée' },
          waiting: { color: 'info', label: 'en attente de réponse' },
          validated: { color: 'new', label: "confirmer la venue dans l'entreprise" },
          approved: { color: 'success', label: 'stage accepté' }
        }
        applications = student.internship_applications
        return states_hash[:must_apply] if applications.empty?

        case ::InternshipApplication.best_state(applications)
        when "drafted"
          states_hash[:must_apply]
        when "expired"
          states_hash[:expired]
        when "canceled_by_student", "canceled_by_student_confirmation"
          states_hash[:canceled]
        when "rejected", "expired_by_student", "canceled_by_employer"
          states_hash[:rejected]
        when "submitted", "read_by_employer", "examined"
          states_hash[:waiting]
        when "validated_by_employer"
          states_hash[:validated]
        when "approved"
          states_hash[:approved]
        end
      end

      Tutor = Struct.new(:tutor_name,
                         :tutor_phone,
                         :tutor_email,
                         :tutor_role,
                         keyword_init: true)
      def internship_tutors
        student.internship_applications
               .select(&:approved?)
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
