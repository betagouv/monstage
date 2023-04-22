module Presenters
  class InternshipApplication
    include ::ActionView::Helpers::DateHelper

    def expires_in
      start = internship_application.updated_at
      finish = start + ::InternshipApplication::EXPIRATION_DURATION
      distance_of_time_in_words_to_now(finish, include_days: true)
    end

    def status
      return "" if internship_application.aasm_state.nil?
      badge = {}
      case internship_application.aasm_state
      when "drafted", "submitted"
        badge = {label: 'nouveau', badge_type:'new'}
      when "examined"
        badge = {label: "à l'étude", badge_type:'info'}
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