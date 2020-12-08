module Presenters
  class UserManagementRole
    def role
      return 'Elève' if user.is_a?(Users::Student)

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
    end

    private

    attr_reader :user
    def initialize(user:)
      @user = user
    end
  end
end
