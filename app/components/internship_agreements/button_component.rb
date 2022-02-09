module InternshipAgreements
  class ButtonComponent < BaseComponent
    attr_reader :internship_agreement, :current_user, :label

    def initialize(internship_agreement:, current_user:, label: "Editer")
      @internship_agreement = internship_agreement
      @current_user = current_user
      @label = button_label
    end

    def button_label
      if @current_user.is_a?(Users::SchoolManagement)
        return school_management_button_label 
      else
        return employer_button_label
      end
    end

    def school_management_button_label
      case @internship_agreement.aasm_state
      when 'draft' then 'En attente'
      when 'started_by_employer' then 'En attente'
      when 'completed_by_employer' then 'Vérifier ma convention'
      else 'Imprimer'
      end  
    end

    def employer_button_label
      case @internship_agreement.aasm_state
      when 'draft' then 'Remplir ma convention'
      when 'started_by_employer' then 'Remplir ma convention'
      when 'completed_by_employer' then 'Voir ma convention'
      else 'Imprimer'
      end  
    end
  end
end
