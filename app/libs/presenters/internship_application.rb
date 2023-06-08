module Presenters
  class InternshipApplication
    include ::ActionView::Helpers::DateHelper

    delegate :student , to: :internship_application
    delegate :internship_offer, to: :internship_application
    delegate :title, to: :internship_offer, prefix: true
    delegate :employer_name, to: :internship_offer

    def expires_in
      start = internship_application.updated_at
      finish = start + ::InternshipApplication::EXPIRATION_DURATION
      finish += internship_application.examined_at.nil? ? 0 : ::InternshipApplication::EXTENDED_DURATION
      distance_of_time_in_words_to_now(finish, include_days: true)
    end

    def internship_offer_address
      internship_application.internship_offer
                            .presenter
                            .address
    end

    def internship_offer_title
      internship_application.internship_offer.title
    end

    def human_state
      case internship_application.aasm_state
      when "drafted"
        student_has_found = internship_application.student
                                                  .has_already_approved_an_application?
        label = student_has_found ? 'Voir' : 'Finaliser ma candidature'
        level = student_has_found ? 'tertiary' : 'primary'
        {label: 'brouillon',
          badge:'grey',
          actions: [ { label: label,
                       path: internship_application_path,
                       level: level
                    }]
        }
      when "submitted"
        label = reader.student? ? 'envoyée' : 'nouveau'
        action_label = reader.student? ? 'Voir' : 'Répondre'
        action_level = reader.student? ? 'tertiary' : 'primary'
        { label: label,
          badge: 'info',
          actions: [ { label: action_label,
                      path: internship_application_path,
                      level: action_level
                    }]
        }
      when "read_by_employer"
        action_label = reader.student? ? 'Voir' : 'Répondre'
        action_level = reader.student? ? 'tertiary' : 'primary'
        { label: "lue",
          badge: 'warning',
          actions: [ { label: action_label,
                      path: internship_application_path,
                      level: action_level
                    }]
        }
      when "examined"
        action_label = reader.student? ? 'Voir' : 'Répondre'
        action_level = reader.student? ? 'tertiary' : 'primary'
        { label: 'à l\'étude',
          badge: 'info',
          actions: [ { label: action_label,
                      path: internship_application_path,
                      level: action_level
                    }]
        }
      when "validated_by_employer"
        label = reader.student? ? 'acceptée par l\'entreprise' : 'en attente de réponse'
        action_label = reader.student? ? 'Répondre' : 'Voir'
        action_level = reader.student? ? 'primary' : 'tertiary'
        badge = reader.student? ? 'success' : 'info'
        { label: label,
          badge: badge,
          actions: [ { label: action_label,
                      path: internship_application_path,
                      level: action_level
                      }]
        }
      when "canceled_by_employer"
        label = reader.student? ? 'annulée par l\'entreprise' : 'refusée'
        { label: 'refusée par l\'entreprise',
          badge: 'error',
          actions: [ { label: 'Voir',
                       path: internship_application_path,
                       level: 'tertiary'
                      }]
        }
      when  "rejected"
        label = reader.student? ? 'refusée par l\'entreprise' : 'refusée'
        { label: 'refusée par l\'entreprise',
          badge: 'error',
          actions: [ { label: 'Voir',
                       path: internship_application_path,
                       level: 'tertiary'
                      }]
        }
      when "canceled_by_student"
        label = reader.student? ? 'annulée' : 'annulée par l\'élève'
        { label: label,
          badge:'purple-glycine',
          actions: [ { label: 'Voir',
                      path: internship_application_path,
                      level: 'tertiary'
                      }]
        }
      when "expired"
        { label: 'expirée',
          badge:'error',
          actions: [ { label: 'Voir',
                      path: internship_application_path,
                      level: 'tertiary'
                      }]
        }
      when "canceled_by_student_confirmation"
        { label: 'annulée',
          badge:'purple-glycine',
          actions: [ { label: 'Voir',
                      path: internship_application_path,
                      level: 'tertiary'
                      }]
        }
      when "approved"
        action_label = reader.student? ? 'Contacter l\'employeur' : 'Voir'
        action_level = reader.student? ? 'primary' : 'secondary'
        { label: "stage validé",
          badge: 'success',
          actions: [ { label: action_label,
                       path: internship_application_path,
                       level: action_level
                      }]
        }
      else
        {}
      end
    end

    def actions_in_show_page
      return "" if internship_application.aasm_state.nil?

      student_has_found = internship_application.student
                                                .has_already_approved_an_application?
      student_has_found ? actions_when_student_has_found : actions_when_student_has_not_found
    end

    def actions_when_student_has_found
      return [] unless internship_application.approved?

      [{ label: 'Contacter l\'offreur',
         color: 'primary',
         level: 'tertiary' }]
    end

    def actions_when_student_has_not_found
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
                :internship_offer,
                :reader

    protected
    def initialize(internship_application, user)
      @reader = user
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