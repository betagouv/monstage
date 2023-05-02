module Presenters
  class InternshipApplication
    include ::ActionView::Helpers::DateHelper

    def expires_in
      start = internship_application.updated_at
      finish = start + ::InternshipApplication::EXPIRATION_DURATION
      distance_of_time_in_words_to_now(finish, include_days: true)
    end

    def internship_location
      internship_application.internship_offer
                            .presenter
                            .address
    end

    def internship_offer_title
      internship_application.internship_offer.title
    end

    def status
      return "" if internship_application.aasm_state.nil?
      badge = {}
      case internship_application.aasm_state
      when "drafted", "submitted"
        badge = {label: 'nouveau', badge_type:'new'}
      when "examined"
        badge = {label: "à l'étude", badge_type:'info'}
      when "validated_by_employer"
        badge = {label: "en attente de réponse", badge_type:'info'}
      when "read_by_employer"
        badge = {label: "lu", badge_type:'warning'}
      when "rejected", "canceled_by_student", "canceled_by_employer"
        badge = {label: "refusé", badge_type: 'error'}
      when "expired"
        badge = {label: "expiré", badge_type:'error'}
      else
        badge = {label: 'accepté', badge_type:'success'}
      end
    end

    def student_human_state
      return "" if internship_application.aasm_state.nil?
      badge = {}
      case internship_application.aasm_state
      when "drafted"
        badge = {label: 'brouillon',
                 badge:'nothing',
                 actions: [ { label: 'modifier',
                             path: Rails.application.routes.url_helpers.root_path,
                             color: 'primary',
                             secondary: true},
                            { label: 'envoyer',
                              path: Rails.application.routes.url_helpers.root_path,
                              color: 'primary',
                              secondary: false}]}
      when "submitted"
        badge = {label: 'en attente de réponse',
          badge:'nothing',
          actions: nil}
      when "read_by_employer"
        badge = {label: 'info',
                 badge:'new',
                 actions: nil}
      when "examined"
        badge = {label: 'A l\'étude',
                 badge:'warning',
                 actions: nil}
      when "validated_by_employer"
        badge = {label: 'en attente de confirmation',
                 badge:'info',
                 actions: [ { label: 'Confirmer',
                             path: Rails.application.routes.url_helpers.root_path,
                             color: 'primary',
                             secondary: false},
                            { label: 'Refuser',
                              path: Rails.application.routes.url_helpers.root_path,
                              color: 'primary',
                              secondary: true }]}

      when "canceled_by_employer", "rejected"
        badge = {label: 'refusé',
                 badge:'error',
                 actions: nil}
      when "canceled_by_student"
        badge = {label: 'annulé',
                 badge:'warning',
                 actions: nil}
      when "expired"
        badge = {label: 'expiré',
                 badge:'error',
                 actions: nil}
      when "approved"
        badge = {label: 'confirmé',
                 badge:'success',
                 actions: nil}
      else
        badge = {}
      end
    end

    attr_reader :internship_application,
                :student,
                :internship_offer
    protected


    def initialize(internship_application)
      @internship_application = internship_application
      @student                = internship_application.student
      @internship_offer       = internship_application.internship_offer
    end
  end
end