module InternshipAgreements
  class ButtonComponent < BaseComponent
    attr_reader :internship_agreement, :current_user, :label, :second_label
    include CanCan::Ability

    def initialize(internship_agreement:,
                   current_user:,
                   label: {status: 'enabled', text: 'Editer'},
                   second_label: {status: 'disabled', text: 'En attente'})
      @internship_agreement = internship_agreement
      @current_user         = current_user
      @label              ||= button_label(user: current_user)
      @second_label       ||= second_button_label
    end

    def started_or_signed?
      %w[validated
         signatures_started
         signed_by_all signed
      ].include?(internship_agreement.aasm_state)
    end

    def on_going_process?
      employer_like = current_user.employer_like?
      after_employer_state = %w[completed_by_employer
                                started_by_school_manager].include?(internship_agreement.aasm_state)
      employer_like || after_employer_state
    end

    def button_label(user:)
      if user.employer_like?
        case @internship_agreement.aasm_state
        when 'draft' then
          {status: 'cta', text: 'Remplir ma convention'}
        when 'started_by_employer' then
          {status: 'cta', text: 'Valider ma convention'}
        when 'completed_by_employer' then
          {status: 'secondary_cta', text: 'Vérifier ma convention'}
        when 'started_by_school_manager' then
          {status: 'secondary_cta', text: 'Vérifier ma convention'}
        when 'validated', 'signatures_started', 'signed_by_all' then
          {status: 'secondary_cta', text: 'Imprimer'}
        end
      else # school_manager
        case @internship_agreement.aasm_state
        when 'draft' then
          {status: 'disabled', text: 'En attente'}
        when 'started_by_employer' then
          {status: 'disabled', text: 'En attente'}
        when 'completed_by_employer' then
          {status: 'cta', text: 'Remplir ma convention'}
        when 'started_by_school_manager' then
          {status: 'cta', text: 'Valider ma convention'}
        when 'validated', 'signatures_started', 'signed_by_all' then
          {status: 'secondary_cta', text: 'Imprimer'}
        end
      end
    end

    def second_button_label
      case @internship_agreement.aasm_state
      when 'draft', 'started_by_employer' ,'completed_by_employer', 'started_by_school_manager' then
        {status: 'hidden', text: ''}
      when 'validated', 'signatures_started' then
        if user_signed_condition 
          {status: 'disabled', text: 'Déjà signée'}
        elsif current_user.can_sign?(@internship_agreement)
          {status: 'enabled', text: 'Ajouter aux signatures'}
        else
          {status: 'hidden', text: ''}
        end
      when 'signed_by_all' then {status: 'disabled', text: 'Signée de tous'}
      end
    end

    def user_signed_condition
      if current_user.school_manager? || current_user.admin_officer?
        @internship_agreement.signed_by_school?
      else
        @internship_agreement.signed_by?(user: current_user)
      end
    end
  end
end
