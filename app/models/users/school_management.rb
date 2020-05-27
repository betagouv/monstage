# frozen_string_literal: true

module Users
  class SchoolManagement < User
    include UserAdmin

    enum role: {
      school_manager: 'school_manager',
      teacher: 'teacher',
      main_teacher: 'main_teacher',
      other: 'other'
    }

    validates :first_name,
              :last_name,
              presence: true

    validates :email, format: /\A[^@\s]+@ac-[^@\s]+\z/, if: :school_manager?

    belongs_to :class_room, optional: true
    has_many :students, through: :class_room
    belongs_to :school, optional: true

    has_many :main_teachers, through: :school

    validate :only_join_managed_school, on: :create, unless: :school_manager?

    before_update :notify_school_manager, if: :notifiable?
    after_create :notify_school_manager, if: :notifiable?

    def self.human_attribute_name_for(role)
      case role.to_sym
      when :school_manager
         "Chef d'établissement"
      when :teacher
         "Professeur"
      when :other
         'Autres fonctions'
      when :main_teacher
         'Professeur principal'
       else
        'Utilisateur'
      end
    end

    def custom_dashboard_path
      return url_helpers.edit_dashboard_school_path(school) if school.present? && school.weeks.size.zero?
      return url_helpers.dashboard_school_class_room_path(school, class_room) if school.present? && class_room.present?
      return url_helpers.dashboard_school_class_rooms_path(school) if school.present?

      url_helpers.account_path
    end

    def custom_dashboard_paths
      [
        after_sign_in_path
      ]
    rescue ActionController::UrlGenerationError
      []
    end

    def dashboard_name
      'Mon Collège'
    end

    private
    # validators
    def only_join_managed_school
      unless school.try(:school_manager).try(:present?)
        errors[:base] << "Le chef d'établissement ne s'est pas encore inscrit, il doit s'inscrire pour confirmer les professeurs principaux."
      end
    end

    # notify
    def notifiable?
      school_id_changed? && school_id? && !school_manager?
    end

    def notify_school_manager
      if school.school_manager.present?
        SchoolManagerMailer.new_member(school_manager: school.school_manager,
                                       member: self)
                           .deliver_later
      end
    end
  end
end
