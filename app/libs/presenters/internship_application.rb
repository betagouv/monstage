module Presenters
  class InternshipApplication
    include ::ActionView::Helpers::DateHelper

    def expires_in
      start = internship_application.updated_at
      finish = start + ::InternshipApplication::EXPIRATION_DURATION
      finish += internship_application.examined_at.nil? ? 0 : ::InternshipApplication::EXTENDED_DURATION
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
      case internship_application.aasm_state
      when "drafted"
        {label: 'brouillon',
          badge:'grey',
          actions: [ { label: 'Voir',
                      path: internship_application_path,
                      color: 'nil',
                      level: 'tertiary'
                    }]
        }
      when "submitted", "read_by_employer"
        { label: 'sans réponse',
          badge: 'info',
          actions: [ { label: 'Renvoyer la demande',
                      path: internship_application_path,
                      color: 'nil',
                      level: 'tertiary'
                    }]
        }
      when "examined"
        { label: 'à l\'étude',
          badge:'info',
          actions: [ { label: 'Renvoyer la demande',
                      path: internship_application_path,
                      color: 'nil',
                      level: 'tertiary'
                    }]
        }
      when "validated_by_employer"
        { label: 'acceptée par l\'entreprise',
          badge:'success',
          actions: [ { label: 'Répondre',
                      path: internship_application_path,
                      color: 'nil',
                      level: 'tertiary'
                      }]
        }
      when "canceled_by_employer", "rejected"
        { label: 'refusée par l\'entreprise',
          badge:'error',
          actions: [ { label: 'Renvoyer la demande',
                      path: internship_application_path,
                      color: 'nil',
                      level: 'tertiary',
                      disabled: true
                      }]
        }
      when "canceled_by_student"
        { label: 'annulée par l\'élève',
          badge:'purple-glycine',
          actions: [ { label: 'Renvoyer la demande',
                      path: internship_application_path,
                      color: 'nil',
                      level: 'tertiary',
                      disabled: true
                      }]
        }
      when "expired"
        { label: 'expirée',
          badge:'error',
          actions: [ { label: 'Renvoyer la demande',
                      path: internship_application_path,
                      color: 'nil',
                      level: 'tertiary',
                      disabled: true
                      }]
        }
      when "canceled_by_student_confirmation"
        {label: 'finalement refusée',
          badge:'purple-glycine',
          actions: [ { label: 'Voir',
                      path: internship_application_path,
                      color: 'nil',
                      level: 'tertiary'
                      }]
        }
      when "approved"
        { label: 'confirmée',
          badge: 'success',
          actions: [ { label: 'Contacter l\'employeur',
                      path: internship_application_path, # peut-être mettre un mailto vers l'offreur ?
                      color: 'nil',
                      level: 'tertiary'
                      }]
        }
      else
        {}
      end
    end

    def no_cancelling_possibility_states
      %w[rejected
        canceled_by_employer
        canceled_by_student
        expired
        drafted
        canceled_by_student_confirmation]
    end

    def with_no_cancelling_possibility?
      no_cancelling_possibility_states.include?(internship_application.aasm_state)
    end

    def actions_in_show_page
      return "" if internship_application.aasm_state.nil?

      case internship_application.aasm_state
      when "drafted"
        [{ label: 'Modifier',
            link_path: edit_internship_application_path,
            color: 'primary',
            level: 'secondary'
          }, {
            label: 'Envoyer la demande',
            form_path: internship_application_path,
            transition: "submit!",
            color: 'primary',
            level: 'primary'}]

      when "submitted", "examined"
         [{ label: 'Renvoyer la demande',
            color: 'primary',
            level: 'primary',
          } ]

      when "read_by_employer"
        [ { label: 'Renvoyer la demande',
            color: 'primary',
            level: 'tertiary',
          } ]

      when "validated_by_employer"
        [ { label: 'Choisir ce stage',
            form_path: internship_application_path,
            transition: "approve!",
            color: 'primary',
            level: 'primary'
          } ]
      when "approved"
         [{ label: 'Contacter l\'offreur',
            color: 'primary',
            level: 'tertiary'
        }]

      when "canceled_by_employer", "rejected", "cancelled_by_student", "expired", "canceled_by_student_confirmation"
        []

      else
        []
      end
    end
    
    def ok_for_examine_states
      %w[submitted read_by_employer]
    end

    def ok_for_reject_states
      %w[submitted
        read_by_employer
        examined
        validated_by_employer
        approved]
    end

    def ok_for_employer_validation_states
      %w[submitted examined read_by_employer] 
    end
    
    def ok_for_examine?
      current_state_in_list?(ok_for_examine_states)
    end

    def ok_for_reject?
      current_state_in_list?(ok_for_reject_states)
    end

    def ok_for_employer_validation?
      current_state_in_list?(ok_for_employer_validation_states)
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

    def rails_routes
      Rails.application.routes.url_helpers
    end

    def internship_application_path
      rails_routes.dashboard_students_internship_application_path(
        student_id: internship_application.user_id,
        id: internship_application.id
      )
    end

    def edit_internship_application_path
      rails_routes.edit_dashboard_students_internship_application_path(
        student_id: internship_application.user_id,
        id: internship_application.id
      )
    end

    def current_state_in_list?(state_array)
      state_array.include?(internship_application.aasm_state)
    end

  end
end