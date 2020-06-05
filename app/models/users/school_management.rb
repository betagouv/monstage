# frozen_string_literal: true

module Users
  # involve all adults in school. each are 'roled'
  #   school_manager (first registered, validated due to ac-xxx.fr email)
  #   main_teacher (track and help students in one class)
  #   teacher (any teacher can check & help students [they can choose class_room])
  #   other (involve psychologists, teacher assistants etc...)
  class SchoolManagement < User
    include UserAdmin

    validates :first_name,
              :last_name,
              :role,
              presence: true

    validates :email, format: /\A[^@\s]+@ac-[^@\s]+\z/, if: :school_manager?

    belongs_to :school, optional: true
    belongs_to :class_room, optional: true
    has_many :students, through: :class_room
    has_many :main_teachers, through: :school

    validate :only_join_managed_school, on: :create, unless: :school_manager?

    before_update :notify_school_manager, if: :notifiable?
    after_create :notify_school_manager, if: :notifiable?

    def self.i18n_roles
      rs= roles.map do |ruby_role, pg_role|
        OpenStruct.new(value: ruby_role, text: I18n.t("enum.roles.#{ruby_role}"))
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
      return 'Ma classe' if school.present? && class_room.present?
      return 'Mon collège' if school.present?
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
