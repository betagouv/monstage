module Presenters
  class UserManagementRole
    def role
      case user
      when Users::Student
        'Elève'
      when Users::Employer
        'Offreur'
      when Users::Tutor
        'Tuteur'
      when Users::God
        'Dieu'
      when Users::Operator
        'Operateur'
      when Users::Statistician
        'Référent départemental'
      when Users::MinistryStatistician
        'Référent central'
      when Users::SchoolManagement
        case user.role.to_sym
        when :school_manager
          "Chef d'établissement"
        when :teacher
          'Professeur'
        when :other
          'Autres fonctions'
        when :main_teacher
          'Professeur principal'
        else
          'Utilisateur'
        end
      when Users::Visitor
        'Visiteur'
      else
        'Utilisateur'
      end
    end

    private

    attr_reader :user
    def initialize(user:)
      @user = user
    end
  end
end
