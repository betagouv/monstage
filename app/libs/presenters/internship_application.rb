module Presenters
  class InternshipApplication
    include ::ActionView::Helpers::DateHelper

    delegate :student , to: :internship_application
    delegate :internship_offer, to: :internship_application
    delegate :title, to: :internship_offer, prefix: true
    delegate :employer_name, to: :internship_offer
    delegate :canceled_by_employer_message, to: :internship_application
    delegate :rejected_message, to: :internship_application
    delegate :examined_message, to: :internship_application

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
      action_path = { path: internship_application_path }
      case internship_application.aasm_state
      when "drafted"
        student_has_found = internship_application.student
                                                  .has_already_approved_an_application?
        label = student_has_found ? 'Voir' : 'Finaliser ma candidature'
        level = student_has_found ? 'tertiary' : 'primary'
        
        {label: 'brouillon',
          badge:'grey',
          actions: [action_path.merge(label: label, level: level)]
        }
      when "submitted"
        label = reader.student? || reader.school_management? ? "Sans réponse de l'entreprise" : 'nouveau'
        action_label = reader.student? ? 'Voir' : 'Répondre'
        action_level = reader.student? ? 'tertiary' : 'primary'
        { label: label,
          badge: 'info',
          actions: [action_path.merge(label: action_label, level: action_level)]
        }
      when "read_by_employer"
        label = reader.student? || reader.school_management? ? "Sans réponse de l'entreprise" : 'Lue'
        badge = reader.student? ? 'info' : 'warning'
        action_label = reader.student? || reader.school_management? ? 'Voir' : 'Répondre'
        action_level = reader.student? ? 'tertiary' : 'primary'
        { label: label,
          badge: badge,
          actions: [action_path.merge(label: action_label, level: action_level)]
        }
      when "examined"
        action_label = reader.student? ? 'Voir' : 'Répondre'
        action_level = reader.student? ? 'tertiary' : 'primary'
        { label: 'à l\'étude',
          badge: 'info',
          actions: [action_path.merge(label: action_label, level: action_level)]
        }

      when "transfered"
        action_label = reader.student? ? 'en attente de réponse' : 'transféré'
        action_level = reader.student? ? 'tertiary' : 'primary'
        label = reader.student? ? 'en attente de réponse' : 'transféré'
        { label: label,
          badge: 'info',
          actions: [action_path.merge(label: action_label, level: action_level)]
        }

      when "validated_by_employer"
        label = reader.student? || reader.school_management? ? 'acceptée par l\'entreprise' : 'en attente de réponse'
        action_label = reader.student? ? 'Répondre' : 'Voir'
        action_level = reader.student? ? 'primary' : 'tertiary'
        badge = reader.student? ? 'success' : 'info'
        { label: label,
          badge: badge,
          actions: [action_path.merge(label: action_label, level: action_level)]
        }
      when "canceled_by_employer"
        label = reader.student? || reader.school_management? ? 'annulée par l\'entreprise' : 'refusée'
        { label: 'refusée par l\'entreprise',
          badge: 'error',
          actions: [action_path.merge(label: 'Voir', level: 'tertiary')]
        }
      when  "rejected"
        label = reader.student? || reader.school_management? ? 'refusée par l\'entreprise' : 'refusée'
        { label: 'refusée par l\'entreprise',
          badge: 'error',
          actions: [action_path.merge(label: 'Voir', level: 'tertiary')]
        }
      when "canceled_by_student"
        label = reader.student? || reader.school_management? ? 'annulée' : 'annulée par l\'élève'
        { label: label,
          badge:'purple-glycine',
          actions: [action_path.merge(label: 'Voir', level: 'tertiary')]
        }
      when "expired"
        { label: 'expirée',
          badge:'error',
          actions: [action_path.merge(label: 'Voir', level: 'tertiary')]
        }
      when "canceled_by_student_confirmation"
        { label: 'annulée',
          badge:'purple-glycine',
          actions: [action_path.merge(label: 'Voir', level: 'tertiary')]
        }
      when "approved"
        action_label = reader.student? ? 'Contacter l\'employeur' : 'Voir'
        action_level = reader.student? ? 'primary' : 'secondary'
        { label: "stage validé",
          badge: 'success',
          actions: [action_path.merge(label: action_label, level: action_level)]
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

      when "transfered", "examined"
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

    def ok_for_examine?
      current_state_in_list?(ok_for_examine_states)
    end

    def ok_for_transfer?
      current_state_in_list?(ok_for_transfer_states)
    end

    def ok_for_reject?
      current_state_in_list?(ok_for_reject_states)
    end

    def ok_for_employer_validation?
      current_state_in_list?(ok_for_employer_validation_states)
    end

    def with_employer_explanation?
      return false unless internship_application.aasm_state.in?(::InternshipApplication.with_employer_explanations_states)

      explanation_count.positive?
    end

    def explanation_count
      count = 0
      count += 1 if internship_application.canceled_by_employer_message?
      count += 1 if internship_application.rejected_message?
      count += 1 if internship_application.examined_message?
      count
    end

    def employer_explanations
      motives = []
      examined_motive = { meth: :examined_message, label: 'Mise à l\'étude par  l\'entreprise' }
      canceled_motive = { meth: :canceled_by_employer_message, label: 'Annulation par l\'entreprise' }
      rejected_motive = { meth: :rejected_message, label: 'Refus par l\'entreprise' }

      motives << examined_motive if internship_application.examined_message?
      motives << examined_motive if internship_application.canceled_by_employer_message?
      motives << rejected_motive if internship_application.rejected_message?

      motives.map do |motive|
        text = internship_application.send(motive[:meth].to_s)
        text.blank? ? nil : "<p><strong>#{motive[:label]}</strong> : </br>#{text}"
      end.compact
      # explanations = []
      # explanations << internship_application.canceled_by_employer_message if internship_application.canceled_by_employer?
      # "#{internship_application.canceled_by_employer_message.to_s}" \
      # "#{internship_application.rejected_message.to_s}" \
      # "#{internship_application.examined_message.to_s}".html_safe
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
        uuid: internship_application.uuid
      )
    end

    def edit_internship_application_path
      rails_routes.edit_dashboard_students_internship_application_path(
        student_id: internship_application.user_id,
        uuid: internship_application.uuid
      )
    end

    private
    
    def current_state_in_list?(state_array)
      state_array.include?(internship_application.aasm_state)
    end
    
    def ok_for_examine_states
      %w[submitted read_by_employer]
    end

    def ok_for_transfer_states
      %w[submitted read_by_employer examined]
    end

    def ok_for_reject_states
      %w[submitted
        read_by_employer
        examined
        transfered
        validated_by_employer
        approved]
    end

    def ok_for_employer_validation_states
      %w[submitted examined transfered read_by_employer]
    end
  end
end