module InternshipAgreements
  class ButtonComponent < BaseComponent
    attr_reader :internship_agreement, :current_user, :label, :second_label

    def initialize(internship_agreement:,
                   current_user:,
                   label: {status: 'enabled', text: 'Editer'},
                   second_label: {status: 'disabled', text: 'En attente'})
      @internship_agreement = internship_agreement
      @current_user         = current_user
      @label              ||= button_label(bool_employer: current_user.employer?)
      @second_label       ||= second_button_label
    end

    def button_label(bool_employer:)
      # when not employer then school_manager
      case @internship_agreement.aasm_state
      when 'draft', 'started_by_employer' then
        employer ? {status: 'enabled', text: 'Remplir ma convention'} :
                   {status: 'disabled', text: 'En attente'}
      when 'completed_by_employer', 'started_by_school_manager' then
        employer ? {status: 'enabled', text: 'Vérifier ma convention'} :
                   {status: 'enabled', text: 'Remplir ma convention'}
      when 'validated', 'signatures_started', 'signed_by_all' then
        {status: 'enabled', text: 'Imprimer'}
      end
    end

    def second_button_label
      case @internship_agreement.aasm_state
      when 'draft', 'started_by_employer' ,'completed_by_employer', 'started_by_school_manager' then
        {status: 'disabled', text: 'Partie signature'}
      when 'validated', 'signatures_started' then
        user_signed_condition = current_user.already_signed?(internship_agreement_id: @internship_agreement.id)
        user_signed_condition ? {status: 'disabled', text: 'Signée, en attente'} :
                                {status: 'enabled', text: 'Signer la convention'}
      when 'signed_by_all' then {status: 'disabled', text: 'Signée de tous'}
      end
    end
  end
end
